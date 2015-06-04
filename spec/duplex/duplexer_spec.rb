require "spec_helper"

describe Duplex::Duplexer do
  let(:datastore) { Duplex::Datastore::Memory.new }
  let(:filestore) { Duplex::Filestore::Memory.new("/") }
  let(:duplex) { Duplex::Duplexer.new(datastore: datastore, filestore: filestore) }

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
