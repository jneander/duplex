require "spec_helper"

describe Duplex::FileImport do
  def add_to_filestore(*file_refs)
    file_refs.each do |file_ref| filestore.add_file(file_ref) end
  end

  let(:datastore) { Duplex::Datastore::Memory.new }
  let(:filestore) { Duplex::Filestore::Memory.new("/") }
  let(:import) { Duplex::FileImport.new(datastore: datastore, filestore: filestore) }

  describe "#from_path" do
    let(:file_ref_1) { create_file_ref }
    let(:file_ref_2) { create_file_ref}

    it "adds all nested files from the given path" do
      add_to_filestore(file_ref_1, file_ref_2)
      import.from_path("/")
      expect(datastore.count).to eql(2)
      expect(datastore.to_a.map(&:path)).to match_array([file_ref_1.path, file_ref_2.path])
    end

    it "ignores files already added" do
      filestore.add_file(file_ref_1)
      datastore.add_file_refs([file_ref_1])
      import.from_path("/")
      expect(datastore.count).to eql(1)
      expect(datastore.to_a.map(&:path)).to match_array([file_ref_1.path])
    end

    it "assigns :size to all imported files" do
      add_to_filestore(file_ref_1, file_ref_2)
      import.from_path("/")
      expect(datastore.count).to eql(2)
      expect(datastore.to_a.map(&:size)).to_not include(nil)
      expect(datastore.to_a.map(&:size)).to match_array([file_ref_1.size, file_ref_2.size])
    end

    it "assigns missing :size to any previously-imported files" do
      add_to_filestore(file_ref_1, file_ref_2)
      datastore.add_file_refs([create_file_ref(file_ref_2.to_hash.merge(size: nil))])
      import.from_path("/")
      expect(datastore.to_a.map(&:size)).to_not include(nil)
      expect(datastore.to_a.map(&:size)).to match_array([file_ref_1.size, file_ref_2.size])
    end

    it "assigns :sha to imported files with duplicate :size" do
      file_ref_1 = create_file_ref(size: 123)
      file_ref_2 = create_file_ref(size: 123)
      add_to_filestore(file_ref_1, file_ref_2)
      import.from_path("/")
      expect(datastore.to_a.map(&:sha)).to_not include(nil)
      expect(datastore.to_a.map(&:sha)).to match_array([file_ref_1.sha, file_ref_2.sha])
    end

    it "assigns missing :sha to previously-imported files with duplicate :size" do
      file_ref_1 = create_file_ref(size: 123)
      file_ref_2 = create_file_ref(size: 123)
      add_to_filestore(file_ref_1, file_ref_2)
      datastore.add_file_refs([create_file_ref(file_ref_2.to_hash.merge(sha: nil))])
      import.from_path("/")
      expect(datastore.to_a.map(&:sha)).to_not include(nil)
      expect(datastore.to_a.map(&:sha)).to match_array([file_ref_1.sha, file_ref_2.sha])
    end

    it "does not reassign :sha on previously-imported files" do
      file_ref_1 = create_file_ref(size: 123)
      file_ref_2 = create_file_ref(size: 123)
      add_to_filestore(file_ref_1, file_ref_2)
      datastore.add_file_refs([create_file_ref(file_ref_2.to_hash.merge(sha: "123ABC"))])
      import.from_path("/")
      expect(datastore.to_a.map(&:sha)).to_not include(nil)
      expect(datastore.to_a.map(&:sha)).to match_array([file_ref_1.sha, "123ABC"])
    end

    it "does not assign :shas for files without a duplicate :size" do
      add_to_filestore(file_ref_1, file_ref_2)
      import.from_path("/")
      expect(datastore.to_a.map(&:sha)).to match_array([nil, nil])
    end
  end
end
