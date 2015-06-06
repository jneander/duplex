require "./spec/duplex/datastore/examples"

describe Duplex::Datastore::FlatFile do
  let(:datastore) { Duplex::Datastore::FlatFile.new(tmp_path("example.msh")) }

  describe "#path" do
    it "stores the path provided at creation" do
      path = tmp_path("/example.msh")
      datastore = Duplex::Datastore::FlatFile.new(path)
      expect(datastore.path).to eql(path)
    end

    it "is required" do
      action = -> {Duplex::Datastore::FlatFile.new}
      expect(action).to raise_error
    end
  end

  it_behaves_like "a FileRef Datastore" do
  end

  describe "#save!" do
    it "persists the file" do
      file_ref = create_file_ref(location: "/example/path") 
      datastore.add_file_refs([file_ref])
      datastore.save!
      duplicate = Duplex::Datastore::FlatFile.new(tmp_path("example.msh"))
      expect(duplicate.find_all_by_path("/example/path").count).to eql(1)
    end
  end
end
