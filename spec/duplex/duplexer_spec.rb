require "spec_helper"

describe Duplex::Duplexer do
  let(:datastore) { Duplex::Datastore::Memory.new }
  let(:filestore) { Duplex::Filestore::Memory.new("/") }
  let(:duplex) { Duplex::Duplexer.new(datastore: datastore, filestore: filestore) }

  describe "#keep" do
    let(:file_ref_1) { create_file_ref }
    let(:file_ref_2) { create_file_ref }

    before(:each) do
      datastore.add_file_refs([file_ref_1, file_ref_2])
    end

    it "sets :decision to :keep on the given FileRefs" do
      duplex.keep([file_ref_1, file_ref_2])
      expect(file_ref_1.decision).to eql(:keep)
      expect(file_ref_2.decision).to eql(:keep)
    end

    it "sets :decision to :keep on the stored instances of the given FileRefs" do
      duplex.keep([file_ref_1, file_ref_2])
      expect(datastore.find_by_path(file_ref_1.path).decision).to eql(:keep)
      expect(datastore.find_by_path(file_ref_2.path).decision).to eql(:keep)
    end

    it "reassigns :decision on both instances" do
      datastore.update(file_ref_1, decision: :prefer)
      duplex.keep([file_ref_1])
      expect(datastore.find_by_path(file_ref_1.path).decision).to eql(:keep)
    end

    it "ignores FileRefs not already stored in the datastore" do
      file_ref_3 = create_file_ref
      duplex.keep([file_ref_3])
      expect(datastore.find_by_path(file_ref_3.path)).to be_nil
    end
  end

  describe "#prefer" do
    let(:file_ref_1) { create_file_ref }
    let(:file_ref_2) { create_file_ref }

    before(:each) do
      datastore.add_file_refs([file_ref_1, file_ref_2])
    end

    it "sets :decision to :prefer on the given FileRefs" do
      duplex.prefer([file_ref_1, file_ref_2])
      expect(file_ref_1.decision).to eql(:prefer)
      expect(file_ref_2.decision).to eql(:prefer)
    end

    it "sets :decision to :prefer on the stored instances of the given FileRefs" do
      duplex.prefer([file_ref_1, file_ref_2])
      expect(datastore.find_by_path(file_ref_1.path).decision).to eql(:prefer)
      expect(datastore.find_by_path(file_ref_2.path).decision).to eql(:prefer)
    end

    it "reassigns :decision on both instances" do
      datastore.update(file_ref_1, decision: :keep)
      duplex.prefer([file_ref_1])
      expect(datastore.find_by_path(file_ref_1.path).decision).to eql(:prefer)
    end

    it "ignores FileRefs not already stored in the datastore" do
      file_ref_3 = create_file_ref
      duplex.prefer([file_ref_3])
      expect(datastore.find_by_path(file_ref_3.path)).to be_nil
    end
  end

  describe "#remove" do
    let(:file_ref_1) { create_file_ref }
    let(:file_ref_2) { create_file_ref }

    before(:each) do
      datastore.add_file_refs([file_ref_1, file_ref_2])
    end

    it "sets :decision to :remove on the given FileRefs" do
      duplex.remove([file_ref_1, file_ref_2])
      expect(file_ref_1.decision).to eql(:remove)
      expect(file_ref_2.decision).to eql(:remove)
    end

    it "sets :decision to :remove on the stored instances of the given FileRefs" do
      duplex.remove([file_ref_1, file_ref_2])
      expect(datastore.find_by_path(file_ref_1.path).decision).to eql(:remove)
      expect(datastore.find_by_path(file_ref_2.path).decision).to eql(:remove)
    end

    it "reassigns :decision on both instances" do
      datastore.update(file_ref_1, decision: :keep)
      duplex.remove([file_ref_1])
      expect(datastore.find_by_path(file_ref_1.path).decision).to eql(:remove)
    end

    it "ignores FileRefs not already stored in the datastore" do
      file_ref_3 = create_file_ref
      duplex.remove([file_ref_3])
      expect(datastore.find_by_path(file_ref_3.path)).to be_nil
    end
  end

  describe "#relocate" do
    let(:file_ref_1) { create_file_ref(location: "/example/path") }
    let(:file_ref_2) { create_file_ref(location: "/nested/example/path") }
    let(:file_ref_3) { create_file_ref(location: "/sample/path") }

    it "sets the :destination for FileRefs matching the given path" do
      file_refs = [file_ref_1, file_ref_2]
      datastore.add_file_refs(file_refs)
      duplex.relocate(file_refs, "example", "relocated")
      expect(datastore.find_by_path(file_ref_1.path).destination).to include("/relocated/path")
      expect(datastore.find_by_path(file_ref_2.path).destination).to include("/nested/relocated/path")
    end

    it "ignores FileRefs not matching the given path" do
      file_refs = [file_ref_1, file_ref_2, file_ref_3]
      datastore.add_file_refs(file_refs)
      duplex.relocate(file_refs, "example", "relocated")
      expect(datastore.find_by_path(file_ref_3.path).destination).to be_nil
    end

    it "accepts regular expressions" do
      file_refs = [file_ref_1, file_ref_2]
      datastore.add_file_refs(file_refs)
      duplex.relocate(file_refs, /example/, "relocated")
      expect(datastore.find_by_path(file_ref_1.path).destination).to include("/relocated/path")
      expect(datastore.find_by_path(file_ref_2.path).destination).to include("/nested/relocated/path")
    end

    it "can use regular expressions for greater precision" do
      file_refs = [file_ref_1, file_ref_2]
      datastore.add_file_refs(file_refs)
      duplex.relocate(file_refs, /^\/example/, "/relocated")
      expect(datastore.find_by_path(file_ref_1.path).destination).to include("/relocated/path")
      expect(datastore.find_by_path(file_ref_2.path).destination).to be_nil
    end

    it "overwrites existing :destinations" do
      file_refs = [file_ref_1, file_ref_2]
      datastore.add_file_refs(file_refs)
      duplex.relocate(file_refs, "example", "relocated")
      duplex.relocate(file_refs, "example", "elsewhere")
      expect(datastore.find_by_path(file_ref_1.path).destination).to include("/elsewhere/path")
      expect(datastore.find_by_path(file_ref_2.path).destination).to include("/nested/elsewhere/path")
    end
  end
end
