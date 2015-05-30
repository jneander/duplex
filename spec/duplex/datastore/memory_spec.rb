require "./spec/duplex/datastore/examples"

describe Duplex::Datastore::Memory do
  let(:datastore) { Duplex::Datastore::Memory.new }

  it_behaves_like "a FileRef Datastore" do
  end

  describe "#save!" do
    it "has no effect" do
      expect(-> {datastore.save!}).to_not raise_error
    end
  end
end
