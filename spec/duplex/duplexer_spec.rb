require "spec_helper"

describe Duplex::Duplexer do
  let(:datastore) { Duplex::Datastore::Memory.new }
  let(:filestore) { Duplex::Filestore::Memory.new("/") }
  let(:duplex) { Duplex::Duplexer.new(datastore: datastore, filestore: filestore) }

  context "during FileRef Selection" do
    let(:file_ref_1) { create_file_ref(sha: "123ABC") }
    let(:file_ref_2) { create_file_ref(sha: "123ABC") }
    let(:file_ref_3) { create_file_ref(sha: "456DEF") }

    before(:each) do
      datastore.add_file_refs([file_ref_1, file_ref_2, file_ref_3])
    end

    describe "#all" do
      it "returns a Selector with all FileRefs in the Datastore" do
        file_refs = [file_ref_1, file_ref_2, file_ref_3]
        spy = create_spy
        duplex.all.each(&spy.block)
        expect(spy.yielded.map(&:path)).to match_array(file_refs.map(&:path))
      end
    end

    describe "#duplicates" do
      it "returns an iterator of duplicate FileRefs Selectors" do
        datastore.add_file_refs([file_ref_1, file_ref_2, file_ref_3])
        expect(duplex.duplicates.count).to eql(1)
        datastore.add_file_refs([create_file_ref(sha: file_ref_3.sha)])
        expect(duplex.duplicates.count).to eql(2)
      end

      it "Selectors yield duplicate FileRef from the Datastore" do
        spy = create_spy
        duplex.duplicates.first.each(&spy.block)
        expect(spy.yielded.map(&:path)).to match_array([file_ref_1.path, file_ref_2.path])
      end
    end

    describe "#unique" do
      it "returns a Selector with unique FileRefs in the Datastore" do
        file_refs = [file_ref_1, file_ref_2, file_ref_3]
        spy = create_spy
        duplex.unique.each(&spy.block)
        expect(spy.yielded.map(&:path)).to match_array([file_ref_3.path])
      end
    end

    describe "#incomplete" do
      it "returns a Selector with incomplete FileRefs in the Datastore" do
        incompletes = [create_file_ref(sha: nil, size: nil), create_file_ref(sha: nil, size: nil)]
        datastore.add_file_refs(incompletes)
        spy = create_spy
        duplex.incomplete.each(&spy.block)
        expect(spy.yielded.map(&:path)).to match_array(incompletes.map(&:path))
      end
    end

    describe "#missing" do
      it "returns a Selector with missing FileRefs in the Datastore" do
        filestore.add_file(file_ref_2)
        spy = create_spy
        duplex.missing.each(&spy.block)
        expect(spy.yielded.map(&:path)).to match_array([file_ref_1.path, file_ref_3.path])
      end
    end
  end

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

  describe "#drop" do
    let(:file_ref_1) { create_file_ref }
    let(:file_ref_2) { create_file_ref }

    it "removes the given FileRefs from the Datastore" do
      datastore.add_file_refs([file_ref_1, file_ref_2])
      duplex.drop([file_ref_1, file_ref_2])
      expect(datastore.exists?(file_ref_1)).to eql(false)
      expect(datastore.exists?(file_ref_2)).to eql(false)
    end

    it "has no effect on other FileRefs in the Datastore" do
      datastore.add_file_refs([file_ref_1, file_ref_2])
      duplex.drop([file_ref_2])
      expect(datastore.exists?(file_ref_1)).to eql(true)
      expect(datastore.exists?(file_ref_2)).to eql(false)
    end

    it "has no effect when given FileRefs not present in the Datastore" do
      datastore.add_file_refs([file_ref_1, file_ref_2])
      duplex.drop([create_file_ref, file_ref_2])
      expect(datastore.exists?(file_ref_2)).to eql(false)
    end
  end

  describe "#save!" do
    it "saves changes to the Datastore" do
      datastore.add_file_refs([create_file_ref, create_file_ref])
      expect(datastore.unsaved_changes?).to eql(true)
      duplex.save!
      expect(datastore.unsaved_changes?).to eql(false)
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
