require "digest"
require "fileutils"

require "./spec/duplex/filestore/examples"

describe Duplex::Filestore::Localdisk do
  def add_file(attr)
    full_path = File.join(tmp_path, attr[:path])
    FileUtils.mkdir_p(File.dirname(full_path))
    File.new(full_path, "w+").write(attr[:content])
    Duplex::FileRef.new(path: full_path)
  end

  def get_size(file_ref)
    File.size(file_ref.path)
  end

  def get_sha(file_ref)
    Digest::SHA1.file(file_ref.path).hexdigest
  end

  it_behaves_like "a Filestore" do
    let(:filestore) { Duplex::Filestore::Localdisk.new(tmp_path) }
  end
end
