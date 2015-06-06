require "./spec/duplex/datastore/examples"

describe Duplex::Datastore::Memory do
  let(:datastore) { Duplex::Datastore::Memory.new }

  it_behaves_like "a FileRef Datastore" do
  end

  describe "#path" do
    it "stores the path provided at creation" do
      path = "/path.msh"
      datastore = Duplex::Datastore::Memory.new(path)
      expect(datastore.path).to eql(path)
    end

    it "is optional" do
      expect(datastore.path).to eql(:none)
    end
  end

  describe "#save!" do
    it "has no effect" do
      expect(-> {datastore.save!}).to_not raise_error
    end
  end
end
