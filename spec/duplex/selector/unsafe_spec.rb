require "spec_helper"

describe Duplex::Selector::Unsafe do
  def select(*refs)
    Duplex::Selector::Unsafe.new(refs)
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
      ref_1 = create_file_ref(name: name_1, location: "/example/path/1")
      ref_2 = create_file_ref(name: name_1, location: "/example/path/2")
      ref_3 = create_file_ref(name: name_1, location: "/example/path/3")
      select(ref_1, ref_2, ref_3).with_uniq_name do |included, excluded|
        expect(included).to match_array([ref_1, ref_2, ref_3])
        expect(excluded).to eql([])
      end
    end

    it "does not match when FileRefs have different names" do
      ref_1 = create_file_ref(name: name_1, location: "/example/path/1")
      ref_2 = create_file_ref(name: name_1, location: "/example/path/2")
      ref_3 = create_file_ref(name: name_2, location: "/example/path/3")
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

  describe "#each" do
    it "yields each FileRef to the block" do
      refs = [create_file_ref, create_file_ref, create_file_ref]
      paths = []
      select(*refs).each do |file_ref|
        paths << file_ref.path
      end
      expect(paths.count).to eql(3)
      expect(paths).to match_array(refs.map(&:path))
    end

    it "has no effect when no block is given" do
      expect(->{select().each}).to_not raise_error
    end
  end

  describe "#all" do
    it "calls the given block" do
      called = false
      select.all do
        called = true
      end
      expect(called).to eql(true)
    end

    it "yields all FileRefs to the block" do
      refs = [create_file_ref, create_file_ref, create_file_ref]
      select(*refs).all do |file_refs|
        expect(file_refs.count).to eql(3)
        expect(file_refs.map(&:path)).to match_array(refs.map(&:path))
      end
    end

    it "yields an empty array when no FileRefs have been stored" do
      select().all do |file_refs|
        expect(file_refs).to be_empty
      end
    end

    it "has no effect when no block is given" do
      expect(->{select().all}).to_not raise_error
    end
  end

  context "when chaining selectors" do
    let(:refs) {[
      create_file_ref(path: "/example/path/document.txt"),
      create_file_ref(path: "/example/dir/text.doc"),
      create_file_ref(path: "/sample/path/document.txt")
    ]}

    describe "#with_path" do
      it "combines with results from a previous selection" do
        select(*refs).with_name("document").with_path("/example") do |included, excluded|
          expect(included).to match_array([refs[0]])
          expect(excluded).to match_array([refs[1], refs[2]])
        end
      end

      it "returns self" do
        selector = select(*refs)
        expect(selector.with_path("/example")).to equal(selector)
      end
    end

    describe "#with_name" do
      it "combines with results from a previous selection" do
        select(*refs).with_path("/example").with_name("document") do |included, excluded|
          expect(included).to match_array([refs[0]])
          expect(excluded).to match_array([refs[1], refs[2]])
        end
      end

      it "returns self" do
        selector = select(*refs)
        expect(selector.with_name("document")).to equal(selector)
      end
    end

    describe "#with_ext" do
      it "combines with results from a previous selection" do
        select(*refs).with_path("/example").with_ext("txt") do |included, excluded|
          expect(included).to match_array([refs[0]])
          expect(excluded).to match_array([refs[1], refs[2]])
        end
      end

      it "returns self" do
        selector = select(*refs)
        expect(selector.with_ext("txt")).to equal(selector)
      end
    end

    describe "#with_sha" do
      it "combines with results from a previous selection" do
        select(*refs).with_path("/example").with_sha(refs[0].sha) do |included, excluded|
          expect(included).to match_array([refs[0]])
          expect(excluded).to match_array([refs[1], refs[2]])
        end
      end

      it "yields an empty array when combined results are empty" do
        select(*refs).with_path("/sample").with_sha(refs[0].sha) do |included, excluded|
          expect(included).to match_array([])
          expect(excluded).to match_array(refs)
        end
      end

      it "returns self" do
        selector = select(*refs)
        expect(selector.with_sha(refs[0].sha)).to equal(selector)
      end
    end

    describe "#with_size" do
      it "combines with results from a previous selection" do
        select(*refs).with_path("/example").with_size(refs[0].size) do |included, excluded|
          expect(included).to match_array([refs[0]])
          expect(excluded).to match_array([refs[1], refs[2]])
        end
      end

      it "yields an empty array when combined results are empty" do
        select(*refs).with_path("/sample").with_size(refs[0].size) do |included, excluded|
          expect(included).to match_array([])
          expect(excluded).to match_array(refs)
        end
      end

      it "returns self" do
        selector = select(*refs)
        expect(selector.with_size(refs[0].size)).to equal(selector)
      end
    end

    describe "#with_uniq_name" do
      it "combines with results from a previous selection" do
        select(*refs).with_path("/path/").with_uniq_name do |included, excluded|
          expect(included).to match_array([refs[0], refs[2]])
          expect(excluded).to match_array([refs[1]])
        end
      end

      it "yields an empty array when combined results are empty" do
        select(*refs).with_path("/example").with_uniq_name do |included, excluded|
          expect(included).to match_array([])
          expect(excluded).to match_array(refs)
        end
      end

      it "returns self" do
        selector = select(*refs)
        expect(selector.with_uniq_name).to equal(selector)
      end
    end

    describe "#with_uniq_location" do
      let(:refs) {[
        create_file_ref(path: "/example/path/document.txt"),
        create_file_ref(path: "/example/path/text.txt"),
        create_file_ref(path: "/sample/path/document.doc")
      ]}

      it "combines with results from a previous selection" do
        select(*refs).with_ext("txt").with_uniq_location do |included, excluded|
          expect(included).to match_array([refs[0], refs[1]])
          expect(excluded).to match_array([refs[2]])
        end
      end

      it "yields an empty array when combined results are empty" do
        select(*refs).with_name("document").with_uniq_location do |included, excluded|
          expect(included).to match_array([])
          expect(excluded).to match_array(refs)
        end
      end

      it "returns self" do
        selector = select(*refs)
        expect(selector.with_uniq_location).to equal(selector)
      end
    end

    describe "#each" do
      it "yields with results from a previous selection" do
        yielded = []
        select(*refs).with_path("/example").each do |file_ref|
          yielded << file_ref
        end
        expect(yielded.count).to eql(2)
        expect(yielded).to match_array([refs[0], refs[1]])
      end
    end

    describe "#all" do
      it "yields with results from a previous selection" do
        yielded = []
        select(*refs).with_path("/example").all do |file_refs|
          yielded = file_refs
        end
        expect(yielded.count).to eql(2)
        expect(yielded).to match_array([refs[0], refs[1]])
      end
    end
  end
end
