require "spec_helper"

describe Duplex::Selector do
  def select(*refs)
    Duplex::Selector.new(refs)
  end

  describe "#with_path" do
    let(:location_1) { "/example_path" }
    let(:location_2) { "/sample_path" }

    it "calls the given block" do
      called = false
      select.with_path("/example_path") do
        called = true
      end
      expect(called).to eql(true)
    end

    it "divides FileRefs using the given path" do
      ref_1 = create_file_ref(location: location_1)
      ref_2 = create_file_ref(location: location_1)
      ref_3 = create_file_ref(location: location_2)
      select(ref_1, ref_2, ref_3).with_path("/example_path") do |included, excluded|
        expect(included).to match_array([ref_1, ref_2])
        expect(excluded).to eql([ref_3])
      end
    end

    it "matches with nested paths" do
      ref_1 = create_file_ref(location: location_1)
      ref_2 = create_file_ref(location: location_2)
      select(ref_1, ref_2).with_path("ample_path") do |included, excluded|
        expect(included).to match_array([ref_1, ref_2])
        expect(excluded).to eql([])
      end
    end

    it "accepts regular expressions" do
      ref_1 = create_file_ref(location: location_1)
      ref_2 = create_file_ref(location: location_1)
      ref_3 = create_file_ref(location: location_2)
      select(ref_1, ref_2, ref_3).with_path(/example_path/) do |included, excluded|
        expect(included).to match_array([ref_1, ref_2])
        expect(excluded).to eql([ref_3])
      end
    end

    it "can use regular expressions for greater precision" do
      ref_1 = create_file_ref(location: "/example_path")
      ref_2 = create_file_ref(location: "/nested/example_path")
      select(ref_1, ref_2).with_path(/^\/example_path/) do |included, excluded|
        expect(included).to match_array([ref_1])
        expect(excluded).to eql([ref_2])
      end
    end
  end

  describe "#with_name" do
    let(:name_1) { "example_name" }
    let(:name_2) { "sample_name" }

    it "calls the given block" do
      called = false
      select.with_name("/example_path") do
        called = true
      end
      expect(called).to eql(true)
    end

    it "divides FileRefs using the given name" do
      ref_1 = create_file_ref(name: name_1)
      ref_2 = create_file_ref(name: name_1)
      ref_3 = create_file_ref(name: name_2)
      select(ref_1, ref_2, ref_3).with_name("example_name") do |included, excluded|
        expect(included).to match_array([ref_1, ref_2])
        expect(excluded).to eql([ref_3])
      end
    end

    it "matches with partial names" do
      ref_1 = create_file_ref(name: name_1)
      ref_2 = create_file_ref(name: name_2)
      select(ref_1, ref_2).with_name("ample_name") do |included, excluded|
        expect(included).to match_array([ref_1, ref_2])
        expect(excluded).to eql([])
      end
    end

    it "accepts regular expressions" do
      ref_1 = create_file_ref(name: name_1)
      ref_2 = create_file_ref(name: name_1)
      ref_3 = create_file_ref(name: name_2)
      select(ref_1, ref_2, ref_3).with_name(/example_name/) do |included, excluded|
        expect(included).to match_array([ref_1, ref_2])
        expect(excluded).to eql([ref_3])
      end
    end

    it "can use regular expressions for greater precision" do
      ref_1 = create_file_ref(name: "example_name")
      ref_2 = create_file_ref(name: "other_example_name")
      select(ref_1, ref_2).with_name(/^example_name/) do |included, excluded|
        expect(included).to match_array([ref_1])
        expect(excluded).to eql([ref_2])
      end
    end
  end

  describe "#with_ext" do
    let(:ext_1) { ".jpg" }
    let(:ext_2) { ".png" }

    it "calls the given block" do
      called = false
      select.with_ext(ext_1) do
        called = true
      end
      expect(called).to eql(true)
    end

    it "divides FileRefs using the given extension" do
      ref_1 = create_file_ref(ext: ext_1)
      ref_2 = create_file_ref(ext: ext_1)
      ref_3 = create_file_ref(ext: ext_2)
      select(ref_1, ref_2, ref_3).with_ext(ext_1) do |included, excluded|
        expect(included).to match_array([ref_1, ref_2])
        expect(excluded).to eql([ref_3])
      end
    end

    it "matches without a dot" do
      ref_1 = create_file_ref(ext: ext_1)
      select(ref_1).with_ext(ext_1.delete(".")) do |included, excluded|
        expect(included).to match_array([ref_1])
        expect(excluded).to eql([])
      end
    end
  end

  describe "#with_sha" do
    let(:sha_1) { "da39a3ee5e6b4b0d3255bfef95601890afd80709" }
    let(:sha_2) { "adc83b19e793491b1c6ea0fd8b46cd9f32e592fc" }

    it "calls the given block" do
      called = false
      select.with_sha(sha_1) do
        called = true
      end
      expect(called).to eql(true)
    end

    it "divides FileRefs using the given sha" do
      ref_1 = create_file_ref(sha: sha_1)
      ref_2 = create_file_ref(sha: sha_1)
      ref_3 = create_file_ref(sha: sha_2)
      select(ref_1, ref_2, ref_3).with_sha(sha_1) do |included, excluded|
        expect(included).to match_array([ref_1, ref_2])
        expect(excluded).to eql([ref_3])
      end
    end

    it "matches only exact shas" do
      ref_1 = create_file_ref(sha: sha_1)
      ref_2 = create_file_ref(sha: sha_2)
      select(ref_1, ref_2).with_sha(sha_1[0...-1]) do |included, excluded|
        expect(included).to match_array([])
        expect(excluded).to eql([ref_1, ref_2])
      end
    end
  end

  describe "#with_size" do
    it "calls the given block" do
      called = false
      select.with_size(123) do
        called = true
      end
      expect(called).to eql(true)
    end

    it "divides FileRefs using the given size" do
      ref_1 = create_file_ref(size: 123)
      ref_2 = create_file_ref(size: 123)
      ref_3 = create_file_ref(size: 1234)
      select(ref_1, ref_2, ref_3).with_size(123) do |included, excluded|
        expect(included).to match_array([ref_1, ref_2])
        expect(excluded).to eql([ref_3])
      end
    end

    it "compares with a range when given two values" do
      ref_1 = create_file_ref(size: 122)
      ref_2 = create_file_ref(size: 123)
      ref_3 = create_file_ref(size: 456)
      ref_4 = create_file_ref(size: 457)
      select(ref_1, ref_2, ref_3, ref_4).with_size(123, 456) do |included, excluded|
        expect(included).to match_array([ref_2, ref_3])
        expect(excluded).to eql([ref_1, ref_4])
      end
    end

    it "uses an infinite range when second value is '-1'" do
      ref_1 = create_file_ref(size: 122)
      ref_2 = create_file_ref(size: 123)
      ref_3 = create_file_ref(size: 456)
      select(ref_1, ref_2, ref_3).with_size(123, -1) do |included, excluded|
        expect(included).to match_array([ref_2, ref_3])
        expect(excluded).to eql([ref_1])
      end
    end
  end

  describe "#relocate" do
    it "assigns a :destination based on each FileRef :path" do
      ref_1 = create_file_ref(path: "/original_path/file-1.jpg")
      ref_2 = create_file_ref(path: "/original_path/file-2.jpg")
      select(ref_1, ref_2).relocate("/original_path/", "/updated_path/")
      expect(ref_1.destination).to eql("/updated_path/file-1.jpg")
      expect(ref_2.destination).to eql("/updated_path/file-2.jpg")
    end

    it "matches with nested paths" do
      ref_1 = create_file_ref(path: "/nested/original_path/file-1.jpg")
      ref_2 = create_file_ref(path: "/nested/original_path/file-2.jpg")
      select(ref_1, ref_2).relocate("/original_path/", "/updated_path/")
      expect(ref_1.destination).to eql("/nested/updated_path/file-1.jpg")
      expect(ref_2.destination).to eql("/nested/updated_path/file-2.jpg")
    end

    it "accepts regular expressions" do
      ref_1 = create_file_ref(path: "/original_path/file-1.jpg")
      ref_2 = create_file_ref(path: "/nested/original_path/file-2.jpg")
      select(ref_1, ref_2).relocate(/original_path/, "updated_path")
      expect(ref_1.destination).to eql("/updated_path/file-1.jpg")
      expect(ref_2.destination).to eql("/nested/updated_path/file-2.jpg")
    end

    it "ignores files without a matching :path" do
      ref_1 = create_file_ref(path: "/original_path/file-1.jpg")
      ref_2 = create_file_ref(path: "/different_path/file-2.jpg")
      select(ref_1, ref_2).relocate("original_path", "updated_path")
      expect(ref_1.destination).to eql("/updated_path/file-1.jpg")
      expect(ref_2.destination).to be_nil
    end

    it "can use regular expressions for greater precision" do
      ref_1 = create_file_ref(path: "/original_path/file-1.jpg")
      ref_2 = create_file_ref(path: "/nested/original_path/file-2.jpg")
      select(ref_1, ref_2).relocate(/^\/original_path/, "/updated_path")
      expect(ref_1.destination).to eql("/updated_path/file-1.jpg")
      expect(ref_2.destination).to be_nil
    end
  end

  describe "#with_uniq_name" do
    let(:name_1) { "example_name" }
    let(:name_2) { "sample_name" }

    it "calls the given block" do
      called = false
      select.with_uniq_name do
        called = true
      end
      expect(called).to eql(true)
    end

    it "matches when all FileRefs have the same name" do
      ref_1 = create_file_ref(name: name_1)
      ref_2 = create_file_ref(name: name_1)
      ref_3 = create_file_ref(name: name_1)
      select(ref_1, ref_2, ref_3).with_uniq_name do |included, excluded|
        expect(included).to match_array([ref_1, ref_2, ref_3])
        expect(excluded).to eql([])
      end
    end

    it "does not match when FileRefs have different names" do
      ref_1 = create_file_ref(name: name_1)
      ref_2 = create_file_ref(name: name_1)
      ref_3 = create_file_ref(name: name_2)
      select(ref_1, ref_2, ref_3).with_uniq_name do |included, excluded|
        expect(included).to match_array([])
        expect(excluded).to eql([ref_1, ref_2, ref_3])
      end
    end
  end

  describe "#with_uniq_location" do
    let(:location_1) { "/example_path" }
    let(:location_2) { "/sample_path" }

    it "calls the given block" do
      called = false
      select.with_uniq_location do
        called = true
      end
      expect(called).to eql(true)
    end

    it "matches when all FileRefs have the same location" do
      ref_1 = create_file_ref(location: location_1)
      ref_2 = create_file_ref(location: location_1)
      ref_3 = create_file_ref(location: location_1)
      select(ref_1, ref_2, ref_3).with_uniq_location do |included, excluded|
        expect(included).to match_array([ref_1, ref_2, ref_3])
        expect(excluded).to eql([])
      end
    end

    it "does not match when FileRefs have different location" do
      ref_1 = create_file_ref(location: location_1)
      ref_2 = create_file_ref(location: location_1)
      ref_3 = create_file_ref(location: location_2)
      select(ref_1, ref_2, ref_3).with_uniq_location do |included, excluded|
        expect(included).to match_array([])
        expect(excluded).to eql([ref_1, ref_2, ref_3])
      end
    end
  end

  context "when chaining selectors" do
  end
end
