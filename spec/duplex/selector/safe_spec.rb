require "spec_helper"

require "./spec/duplex/selector/examples"

describe Duplex::Selector::Safe do
  def select(*refs)
    Duplex::Selector::Safe.new(refs)
  end

  describe "#with_path" do
    it_behaves_like "Selector #with_path"

    it "does not yield when no FileRefs match" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      yielded = false
      select(ref_1).with_path("does-not-exist") do |included, excluded|
        yielded = true
      end
      expect(yielded).to eql(false)
    end
  end

  describe "#with_path chained" do
    it_behaves_like "Selector #with_path chained"

    it "does not yield when no FileRefs match a previous selector" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      yielded = false
      select(ref_1).with_name("does-not-exist").with_path("example") do |included, excluded|
        yielded = true
      end
      expect(yielded).to eql(false)
    end
  end

  describe "#with_name" do
    it_behaves_like "Selector #with_name"

    it "does not yield when no FileRefs match" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      yielded = false
      select(ref_1).with_name("does-not-exist") do |included, excluded|
        yielded = true
      end
      expect(yielded).to eql(false)
    end
  end

  describe "#with_name chained" do
    it_behaves_like "Selector #with_name chained"

    it "does not yield when no FileRefs match a previous selector" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      yielded = false
      select(ref_1).with_path("does-not-exist").with_name(ref_1.name) do |included, excluded|
        yielded = true
      end
      expect(yielded).to eql(false)
    end
  end

  describe "#with_ext" do
    it_behaves_like "Selector #with_ext"

    it "does not yield when no FileRefs match" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      yielded = false
      select(ref_1).with_ext("dne") do |included, excluded|
        yielded = true
      end
      expect(yielded).to eql(false)
    end
  end

  describe "#with_ext chained" do
    it_behaves_like "Selector #with_ext chained"

    it "does not yield when no FileRefs match a previous selector" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      yielded = false
      select(ref_1).with_path("does-not-exist").with_ext(ref_1.ext) do |included, excluded|
        yielded = true
      end
      expect(yielded).to eql(false)
    end
  end

  describe "#with_sha" do
    it_behaves_like "Selector #with_sha"

    it "does not yield when no FileRefs match" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      yielded = false
      select(ref_1).with_sha("doesnotexist") do |included, excluded|
        yielded = true
      end
      expect(yielded).to eql(false)
    end
  end

  describe "#with_sha chained" do
    it_behaves_like "Selector #with_sha chained"

    it "does not yield when no FileRefs match a previous selector" do
      ref_1 = create_file_ref(path: "/example/file.txt", sha: "123ABC")
      yielded = false
      select(ref_1).with_path("does-not-exist").with_sha(ref_1.sha) do |included, excluded|
        yielded = true
      end
      expect(yielded).to eql(false)
    end
  end

  describe "#with_size" do
    it_behaves_like "Selector #with_size"

    it "does not yield when no FileRefs match" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      yielded = false
      select(ref_1).with_size(ref_1.size + 1) do |included, excluded|
        yielded = true
      end
      expect(yielded).to eql(false)
    end
  end

  describe "#with_size chained" do
    it_behaves_like "Selector #with_size chained"

    it "does not yield when no FileRefs match a previous selector" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      yielded = false
      select(ref_1).with_path("does-not-exist").with_size(ref_1.size) do |included, excluded|
        yielded = true
      end
      expect(yielded).to eql(false)
    end
  end

  describe "#with_uniq_name" do
    it_behaves_like "Selector #with_uniq_name"

    it "does not yield when no FileRefs match" do
      ref_1 = create_file_ref(name: "file_1")
      ref_2 = create_file_ref(name: "file_2")
      yielded = false
      select(ref_1, ref_2).with_uniq_name do |included, excluded|
        yielded = true
      end
      expect(yielded).to eql(false)
    end
  end

  describe "#with_uniq_name chained" do
    it_behaves_like "Selector #with_uniq_name chained"

    it "does not yield when no FileRefs match a previous selector" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      yielded = false
      select(ref_1).with_path("does-not-exist").with_uniq_name do |included, excluded|
        yielded = true
      end
      expect(yielded).to eql(false)
    end
  end

  describe "#with_uniq_location" do
    it_behaves_like "Selector #with_uniq_location"

    it "does not yield when no FileRefs match" do
      ref_1 = create_file_ref(location: "/example/path")
      ref_2 = create_file_ref(location: "/sample/path")
      yielded = false
      select(ref_1, ref_2).with_uniq_location do |included, excluded|
        yielded = true
      end
      expect(yielded).to eql(false)
    end
  end

  describe "#with_uniq_location chained" do
    it_behaves_like "Selector #with_uniq_location chained"

    it "does not yield when no FileRefs match a previous selector" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      yielded = false
      select(ref_1).with_path("does-not-exist").with_uniq_location do |included, excluded|
        yielded = true
      end
      expect(yielded).to eql(false)
    end
  end

  describe "#each" do
    it_behaves_like "Selector #each"
  end

  describe "#each chained" do
    it_behaves_like "Selector #each chained"
  end

  describe "#all" do
    it_behaves_like "Selector #all"
  end

  describe "#all chained" do
    it_behaves_like "Selector #all chained"

    it "does not yield when no FileRefs match a previous selector" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      yielded = false
      select(ref_1).with_path("does-not-exist").all do |file_refs|
        yielded = true
      end
      expect(yielded).to eql(false)
    end
  end
end
