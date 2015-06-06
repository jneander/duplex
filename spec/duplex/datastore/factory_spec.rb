require "spec_helper"

describe Duplex::Datastore::Factory do
  describe "#get_datastore" do
    it "returns a Datastore initialized with the given path" do
      factory = Duplex::Datastore::Factory.new
      factory_datastore = factory.get_datastore(tmp_path("/datastore.ds"))
      file_ref = create_file_ref
      factory_datastore.add_file_refs([file_ref])
      factory_datastore.save!
      datastore = Duplex::Datastore::FlatFile.new(tmp_path("/datastore.ds"))
      expect(datastore.count).to eql(1)
      expect(datastore.to_a.first.path).to eql(file_ref.path)
    end
  end
end
