require "./spec/duplex/filestore/examples"

describe Duplex::Filestore::Memory do
  def add_file(attr)
    attr[:path] = File.join(tmp_path, attr[:path])
    file_ref = Duplex::FileRef.new(attr)
    filestore.add_file(file_ref)
  end

  def get_size(file_ref)
    file_ref.size
  end

  def get_sha(file_ref)
    file_ref.sha
  end

  it_behaves_like "a Filestore" do
    let(:filestore) { Duplex::Filestore::Memory.new(tmp_path) }
  end
end
