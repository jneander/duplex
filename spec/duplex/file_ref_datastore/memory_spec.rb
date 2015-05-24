require "./spec/duplex/file_ref_datastore/examples"

describe Duplex::FileRefDatastore::Memory do
  let(:datastore) { Duplex::FileRefDatastore::Memory.new }

  it_behaves_like "a FileRef Datastore" do
  end

  describe "#save!" do
    it "has no effect" do
      expect(-> {datastore.save!}).to_not raise_error
    end
  end
end
