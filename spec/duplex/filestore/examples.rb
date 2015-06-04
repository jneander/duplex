require "spec_helper"

shared_examples_for "a Filestore" do
  describe "#entries" do
    before(:each) do
      @example_file = add_file(path: "foo/example", content: "example file")
      @sample_file = add_file(path: "foo/sample", content: "sample file")
    end

    it "returns a list of files in the given path" do
      expect(filestore.entries("foo")).to include(@example_file.path)
      expect(filestore.entries("foo")).to include(@sample_file.path)
    end

    it "includes directories" do
      expect(filestore.entries(".")).to include(File.join(tmp_path, "foo"))
    end

    it "excludes '.' and '..'" do
      expect(filestore.entries(".")).to_not include(".")
      expect(filestore.entries(".")).to_not include("..")
    end

    it "returns an empty list when the given path does not exist" do
      expect(filestore.entries("invalid")).to eql([])
    end
  end

  describe "#nested_files" do
    before(:each) do
      @example_file = add_file(path: "foo/example", content: "example file")
      @sample_file = add_file(path: "foo/sample", content: "sample file")
    end

    it "returns a list of files in the given path" do
      expect(filestore.nested_files("foo")).to include(@example_file.path)
      expect(filestore.nested_files("foo")).to include(@sample_file.path)
    end

    it "includes files within directories" do
      nested_file = add_file(path: "nested/example/file.txt", content: "deeply-nested file")
      expect(filestore.nested_files("nested")).to include(nested_file.path)
    end

    it "includes deeply-nested files" do
      nested_file = add_file(path: "very/deep/example/file.txt", content: "deeply-nested file")
      expect(filestore.nested_files("very")).to include(nested_file.path)
    end

    it "excludes directories" do
      expect(filestore.nested_files(".")).to_not include(File.join(tmp_path, "foo"))
    end

    it "excludes '.' and '..'" do
      expect(filestore.nested_files(".")).to_not include(".")
      expect(filestore.nested_files(".")).to_not include("..")
    end

    it "returns an empty list when the given path does not exist" do
      expect(filestore.nested_files("invalid")).to eql([])
    end
  end

  describe "#move_file" do
    it "moves the given FileRef to the given path" do
      ref = add_file(path: "foo/example")
      updated = filestore.move_file(ref, "bar/example")
      expect(filestore.entries("bar")).to include(updated.path)
    end

    it "returns an updated FileRef with the given path" do
      ref = add_file(path: "foo/example")
      updated = filestore.move_file(ref, "bar/example")
      expect(updated.path).to include(File.join(tmp_path, "bar/example"))
    end
  end

  describe "#assign_size" do
    it "reads and assigns the file :size to the given FileRef" do
      ref = add_file(path: "foo/example", size: 123)
      filestore.assign_size(ref)
      expect(ref.size).to eql(get_size(ref))
    end

    it "does not override existing :size values" do
      example_size = 1
      ref = add_file(path: "foo/example")
      ref.size = example_size
      filestore.assign_size(ref)
      expect(ref.size).to eql(example_size)
    end
  end

  describe "#assign_sha" do
    it "creates and assigns a SHA1 value to the given FileRef" do
      ref = add_file(path: "foo/example")
      filestore.assign_sha(ref)
      expect(ref.sha).to eql(get_sha(ref))
    end

    it "does not override existing :sha values" do
      example_sha = "ddcd95dc85ea5493b68a67b361d8f9b9867554a7"
      ref = add_file(path: "foo/example")
      ref.sha = example_sha
      filestore.assign_sha(ref)
      expect(ref.sha).to eql(example_sha)
    end
  end
end
