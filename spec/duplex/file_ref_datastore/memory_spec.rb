require "./spec/duplex/file_ref_datastore/examples"

describe Duplex::FileRefDatastore::Memory do
  it_behaves_like "a FileRef Datastore" do
    let(:datastore) { Duplex::FileRefDatastore::Memory.new }
  end
end
