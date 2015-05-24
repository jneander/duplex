require "./spec/duplex/file_ref_datastore/examples"

describe Duplex::FileRefDatastore::FlatFile do
  let(:datastore) { Duplex::FileRefDatastore::FlatFile.new(tmp_path("example.msh")) }

  it_behaves_like "a FileRef Datastore" do
  end

  describe "#save!" do
    it "persists the file" do
      datastore.create!(path: "/foo/bar")
      datastore.save!
      duplicate = Duplex::FileRefDatastore::FlatFile.new(tmp_path("example.msh"))
      expect(duplicate.find_in_path("/foo").count).to eql(1)
    end
  end
end
