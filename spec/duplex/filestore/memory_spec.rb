require "./spec/duplex/filestore/examples"

describe Duplex::Filestore::Memory do
  def add_file(attr)
    full_path = File.join(tmp_path, attr[:path])
    file_ref = Duplex::FileRef.new(path: full_path)
    filestore.add_file(file_ref)
  end

  def get_sha(file_ref)
    Digest::SHA1.hexdigest(file_ref.path)
  end

  it_behaves_like "a Filestore" do
    let(:filestore) { Duplex::Filestore::Memory.new(tmp_path) }
  end
end
