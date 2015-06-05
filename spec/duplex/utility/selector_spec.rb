require "spec_helper"

describe Duplex::Selector do
  def select(*refs)
    Duplex::Selector.new(refs)
  end

  describe "#with_path" do
    let(:location_1) { "/example_path" }
    let(:location_2) { "/sample_path" }

    it "calls the given block" do
      ref_1 = create_file_ref(location: location_1)
      spy = create_spy
      select(ref_1).with_path("/example_path", &spy.block)
      expect(spy.called?).to eql(true)
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

    it "does not yield when no FileRefs match" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      spy = create_spy
      select(ref_1).with_path("does-not-exist", &spy.block)
      expect(spy.called?).to eql(false)
    end
  end

  describe "#with_path chained" do
    let(:refs) {[
      create_file_ref(path: "/example/path/document.txt"),
      create_file_ref(path: "/example/dir/text.doc"),
      create_file_ref(path: "/sample/path/document.txt")
    ]}

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

    it "does not yield when no FileRefs match a previous selector" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      spy = create_spy
      select(ref_1).with_name("does-not-exist").with_path("example", &spy.block)
      expect(spy.called?).to eql(false)
    end

    it "does not yield when no FileRefs match combined selectors" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      spy = create_spy
      select(ref_1).with_name("file").with_path("sample", &spy.block)
      expect(spy.called?).to eql(false)
    end
  end

  describe "#with_name" do
    let(:name_1) { "example_name" }
    let(:name_2) { "sample_name" }

    it "calls the given block" do
      ref_1 = create_file_ref(name: name_1)
      spy = create_spy
      select(ref_1).with_name(name_1, &spy.block)
      expect(spy.called?).to eql(true)
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

    it "does not yield when no FileRefs match" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      spy = create_spy
      select(ref_1).with_name("does-not-exist", &spy.block)
      expect(spy.called?).to eql(false)
    end
  end

  describe "#with_name chained" do
    let(:refs) {[
      create_file_ref(path: "/example/path/document.txt"),
      create_file_ref(path: "/example/dir/text.doc"),
      create_file_ref(path: "/sample/path/document.txt")
    ]}

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

    it "does not yield when no FileRefs match a previous selector" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      spy = create_spy
      select(ref_1).with_path("does-not-exist").with_name(ref_1.name, &spy.block)
      expect(spy.called?).to eql(false)
    end

    it "does not yield when no FileRefs match combined selectors" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      spy = create_spy
      select(ref_1).with_path("example").with_name("doesnotexist", &spy.block)
      expect(spy.called?).to eql(false)
    end
  end

  describe "#with_ext" do
    let(:ext_1) { ".jpg" }
    let(:ext_2) { ".png" }

    it "calls the given block" do
      ref_1 = create_file_ref(ext: ext_1)
      spy = create_spy
      select(ref_1).with_ext(ext_1, &spy.block)
      expect(spy.called?).to eql(true)
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

    it "does not yield when no FileRefs match" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      spy = create_spy
      select(ref_1).with_ext("dne", &spy.block)
      expect(spy.called?).to eql(false)
    end
  end

  describe "#with_ext chained" do
    let(:refs) {[
      create_file_ref(path: "/example/path/document.txt"),
      create_file_ref(path: "/example/dir/text.doc"),
      create_file_ref(path: "/sample/path/document.txt")
    ]}

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

    it "does not yield when no FileRefs match a previous selector" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      spy = create_spy
      select(ref_1).with_path("does-not-exist").with_ext(ref_1.ext, &spy.block)
      expect(spy.called?).to eql(false)
    end

    it "does not yield when no FileRefs match combined selectors" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      spy = create_spy
      select(ref_1).with_path("example").with_ext("dne", &spy.block)
      expect(spy.called?).to eql(false)
    end
  end

  describe "#with_sha" do
    let(:sha_1) { "da39a3ee5e6b4b0d3255bfef95601890afd80709" }
    let(:sha_2) { "adc83b19e793491b1c6ea0fd8b46cd9f32e592fc" }

    it "calls the given block" do
      ref_1 = create_file_ref(sha: sha_1)
      spy = create_spy
      select(ref_1).with_sha(sha_1, &spy.block)
      expect(spy.called?).to eql(true)
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
      sha_2 = sha_1[0...-1]
      ref_1 = create_file_ref(sha: sha_1)
      ref_2 = create_file_ref(sha: sha_2)
      select(ref_1, ref_2).with_sha(sha_2) do |included, excluded|
        expect(included).to match_array([ref_2])
        expect(excluded).to eql([ref_1])
      end
    end

    it "does not yield when no FileRefs match" do
      ref_1 = create_file_ref(sha: sha_1)
      spy = create_spy
      select(ref_1).with_sha("doesnotexist", &spy.block)
      expect(spy.called?).to eql(false)
    end
  end

  describe "#with_sha chained" do
    let(:refs) {[
      create_file_ref(path: "/example/path/document.txt"),
      create_file_ref(path: "/example/dir/text.doc"),
      create_file_ref(path: "/sample/path/document.txt")
    ]}

    it "combines with results from a previous selection" do
      select(*refs).with_path("/example").with_sha(refs[0].sha) do |included, excluded|
        expect(included).to match_array([refs[0]])
        expect(excluded).to match_array([refs[1], refs[2]])
      end
    end

    it "returns self" do
      selector = select(*refs)
      expect(selector.with_sha(refs[0].sha)).to equal(selector)
    end

    it "does not yield when no FileRefs match a previous selector" do
      ref_1 = create_file_ref(path: "/example/file.txt", sha: "123ABC")
      spy = create_spy
      select(ref_1).with_path("does-not-exist").with_sha(ref_1.sha, &spy.block)
      expect(spy.called?).to eql(false)
    end

    it "does not yield when no FileRefs match combined selectors" do
      ref_1 = create_file_ref(path: "/example/file.txt", sha: "123ABC")
      spy = create_spy
      select(ref_1).with_path("example").with_sha("456DEF", &spy.block)
      expect(spy.called?).to eql(false)
    end
  end

  describe "#with_size" do
    it "calls the given block" do
      ref_1 = create_file_ref(size: 123)
      spy = create_spy
      select(ref_1).with_size(123, &spy.block)
      expect(spy.called?).to eql(true)
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

    it "does not yield when no FileRefs match" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      spy = create_spy
      select(ref_1).with_size(ref_1.size + 1, &spy.block)
      expect(spy.called?).to eql(false)
    end
  end

  describe "#with_size chained" do
    let(:refs) {[
      create_file_ref(path: "/example/path/document.txt"),
      create_file_ref(path: "/example/dir/text.doc"),
      create_file_ref(path: "/sample/path/document.txt")
    ]}

    it "combines with results from a previous selection" do
      select(*refs).with_path("/example").with_size(refs[0].size) do |included, excluded|
        expect(included).to match_array([refs[0]])
        expect(excluded).to match_array([refs[1], refs[2]])
      end
    end

    it "returns self" do
      selector = select(*refs)
      expect(selector.with_size(refs[0].size)).to equal(selector)
    end

    it "does not yield when no FileRefs match a previous selector" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      spy = create_spy
      select(ref_1).with_path("does-not-exist").with_size(ref_1.size, &spy.block)
      expect(spy.called?).to eql(false)
    end

    it "does not yield when no FileRefs match combined selectors" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      spy = create_spy
      select(ref_1).with_path("example").with_size(ref_1.size + 1, &spy.block)
      expect(spy.called?).to eql(false)
    end
  end

  describe "#with_uniq_name" do
    let(:name_1) { "example_name" }
    let(:name_2) { "sample_name" }

    it "calls the given block" do
      ref_1 = create_file_ref(name: name_1)
      spy = create_spy
      select(ref_1).with_uniq_name(&spy.block)
      expect(spy.called?).to eql(true)
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

    it "does not yield when no FileRefs match" do
      ref_1 = create_file_ref(name: "file_1")
      ref_2 = create_file_ref(name: "file_2")
      spy = create_spy
      select(ref_1, ref_2).with_uniq_name(&spy.block)
      expect(spy.called?).to eql(false)
    end
  end

  describe "#with_uniq_name chained" do
    let(:refs) {[
      create_file_ref(path: "/example/path/document.txt"),
      create_file_ref(path: "/example/dir/text.doc"),
      create_file_ref(path: "/sample/path/document.txt")
    ]}

    it "combines with results from a previous selection" do
      select(*refs).with_path("/path/").with_uniq_name do |included, excluded|
        expect(included).to match_array([refs[0], refs[2]])
        expect(excluded).to match_array([refs[1]])
      end
    end

    it "returns self" do
      selector = select(*refs)
      expect(selector.with_uniq_name).to equal(selector)
    end

    it "does not yield when no FileRefs match a previous selector" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      spy = create_spy
      select(ref_1).with_path("does-not-exist").with_uniq_name(&spy.block)
      expect(spy.called?).to eql(false)
    end

    it "does not yield when no FileRefs match combined selectors" do
      ref_1 = create_file_ref(path: "/example/file_1.txt")
      ref_2 = create_file_ref(path: "/example/file_2.txt")
      spy = create_spy
      select(ref_1, ref_2).with_path("example").with_uniq_name(&spy.block)
      expect(spy.called?).to eql(false)
    end
  end

  describe "#with_uniq_location" do
    let(:location_1) { "/example_path" }
    let(:location_2) { "/sample_path" }

    it "calls the given block" do
      ref_1 = create_file_ref(location: location_1)
      spy = create_spy
      select(ref_1).with_uniq_location(&spy.block)
      expect(spy.called?).to eql(true)
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

    it "does not yield when no FileRefs match" do
      ref_1 = create_file_ref(location: "/example/path")
      ref_2 = create_file_ref(location: "/sample/path")
      spy = create_spy
      select(ref_1, ref_2).with_uniq_location(&spy.block)
      expect(spy.called?).to eql(false)
    end
  end

  describe "#with_uniq_location chained" do
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

    it "returns self" do
      selector = select(*refs)
      expect(selector.with_uniq_location).to equal(selector)
    end

    it "does not yield when no FileRefs match a previous selector" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      spy = create_spy
      select(ref_1).with_name("does-not-exist").with_uniq_location(&spy.block)
      expect(spy.called?).to eql(false)
    end

    it "does not yield when no FileRefs match combined selectors" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      ref_2 = create_file_ref(path: "/sample/file.txt")
      spy = create_spy
      select(ref_1, ref_2).with_name("file").with_uniq_location(&spy.block)
      expect(spy.called?).to eql(false)
    end
  end

  describe "#keeping" do
    it "calls the given block" do
      ref_1 = create_file_ref(decision: :keep)
      spy = create_spy
      select(ref_1).keeping(&spy.block)
      expect(spy.called?).to eql(true)
    end

    it "divides FileRefs using the given :decision" do
      ref_1 = create_file_ref(decision: :keep)
      ref_2 = create_file_ref(decision: :prefer)
      ref_3 = create_file_ref(decision: :remove)
      ref_4 = create_file_ref(decision: :keep)
      select(ref_1, ref_2, ref_3, ref_4).keeping do |included, excluded|
        expect(included).to match_array([ref_1, ref_4])
        expect(excluded).to eql([ref_2, ref_3])
      end
    end

    it "does not yield when no FileRefs match" do
      ref_1 = create_file_ref(decision: :remove)
      spy = create_spy
      select(ref_1).keeping(&spy.block)
      expect(spy.called?).to eql(false)
    end
  end

  describe "#keeping chained" do
    let(:refs) {[
      create_file_ref(location: "/example", decision: :keep),
      create_file_ref(location: "/example", decision: :prefer),
      create_file_ref(location: "/sample", decision: :remove)
    ]}

    it "combines with results from a previous selection" do
      select(*refs).with_path("/example").keeping do |included, excluded|
        expect(included).to match_array([refs[0]])
        expect(excluded).to match_array([refs[1], refs[2]])
      end
    end

    it "returns self" do
      selector = select(*refs)
      expect(selector.keeping).to equal(selector)
    end

    it "does not yield when no FileRefs match a previous selector" do
      ref_1 = create_file_ref(path: "/example/file.txt", decision: :keep)
      spy = create_spy
      select(ref_1).with_path("does-not-exist").keeping(&spy.block)
      expect(spy.called?).to eql(false)
    end

    it "does not yield when no FileRefs match combined selectors" do
      ref_1 = create_file_ref(path: "/example/file.txt", decision: :remove)
      spy = create_spy
      select(ref_1).with_path("example").keeping(&spy.block)
      expect(spy.called?).to eql(false)
    end
  end

  describe "#preferred" do
    it "calls the given block" do
      ref_1 = create_file_ref(decision: :prefer)
      spy = create_spy
      select(ref_1).preferred(&spy.block)
      expect(spy.called?).to eql(true)
    end

    it "divides FileRefs using the given :decision" do
      ref_1 = create_file_ref(decision: :prefer)
      ref_2 = create_file_ref(decision: :keep)
      ref_3 = create_file_ref(decision: :remove)
      ref_4 = create_file_ref(decision: :prefer)
      select(ref_1, ref_2, ref_3, ref_4).preferred do |included, excluded|
        expect(included).to match_array([ref_1, ref_4])
        expect(excluded).to eql([ref_2, ref_3])
      end
    end

    it "does not yield when no FileRefs match" do
      ref_1 = create_file_ref(decision: :keep)
      spy = create_spy
      select(ref_1).preferred(&spy.block)
      expect(spy.called?).to eql(false)
    end
  end

  describe "#preferred chained" do
    let(:refs) {[
      create_file_ref(location: "/example", decision: :prefer),
      create_file_ref(location: "/example", decision: :keep),
      create_file_ref(location: "/sample", decision: :remove)
    ]}

    it "combines with results from a previous selection" do
      select(*refs).with_path("/example").preferred do |included, excluded|
        expect(included).to match_array([refs[0]])
        expect(excluded).to match_array([refs[1], refs[2]])
      end
    end

    it "returns self" do
      selector = select(*refs)
      expect(selector.preferred).to equal(selector)
    end

    it "does not yield when no FileRefs match a previous selector" do
      ref_1 = create_file_ref(path: "/example/file.txt", decision: :prefer)
      spy = create_spy
      select(ref_1).with_path("does-not-exist").preferred(&spy.block)
      expect(spy.called?).to eql(false)
    end

    it "does not yield when no FileRefs match combined selectors" do
      ref_1 = create_file_ref(path: "/example/file.txt", decision: :remove)
      spy = create_spy
      select(ref_1).with_path("example").preferred(&spy.block)
      expect(spy.called?).to eql(false)
    end
  end

  describe "#removing" do
    it "calls the given block" do
      ref_1 = create_file_ref(decision: :remove)
      spy = create_spy
      select(ref_1).removing(&spy.block)
      expect(spy.called?).to eql(true)
    end

    it "divides FileRefs using the given :decision" do
      ref_1 = create_file_ref(decision: :remove)
      ref_2 = create_file_ref(decision: :keep)
      ref_3 = create_file_ref(decision: :prefer)
      ref_4 = create_file_ref(decision: :remove)
      select(ref_1, ref_2, ref_3, ref_4).removing do |included, excluded|
        expect(included).to match_array([ref_1, ref_4])
        expect(excluded).to eql([ref_2, ref_3])
      end
    end

    it "does not yield when no FileRefs match" do
      ref_1 = create_file_ref(decision: :keep)
      spy = create_spy
      select(ref_1).removing(&spy.block)
      expect(spy.called?).to eql(false)
    end
  end

  describe "#removing chained" do
    let(:refs) {[
      create_file_ref(location: "/example", decision: :remove),
      create_file_ref(location: "/example", decision: :keep),
      create_file_ref(location: "/sample", decision: :prefer)
    ]}

    it "combines with results from a previous selection" do
      select(*refs).with_path("/example").removing do |included, excluded|
        expect(included).to match_array([refs[0]])
        expect(excluded).to match_array([refs[1], refs[2]])
      end
    end

    it "returns self" do
      selector = select(*refs)
      expect(selector.removing).to equal(selector)
    end

    it "does not yield when no FileRefs match a previous selector" do
      ref_1 = create_file_ref(path: "/example/file.txt", decision: :remove)
      spy = create_spy
      select(ref_1).with_path("does-not-exist").removing(&spy.block)
      expect(spy.called?).to eql(false)
    end

    it "does not yield when no FileRefs match combined selectors" do
      ref_1 = create_file_ref(path: "/example/file.txt", decision: :keep)
      spy = create_spy
      select(ref_1).with_path("example").removing(&spy.block)
      expect(spy.called?).to eql(false)
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

  describe "#each chained" do
    let(:refs) {[
      create_file_ref(path: "/example/path/document.txt"),
      create_file_ref(path: "/example/dir/text.doc"),
      create_file_ref(path: "/sample/path/document.txt")
    ]}

    it "yields with results from a previous selection" do
      spy = create_spy
      select(*refs).with_path("/example").each(&spy.block)
      expect(spy.yielded.count).to eql(2)
      expect(spy.yielded).to match_array([refs[0], refs[1]])
    end
  end

  describe "#all" do
    it "calls the given block" do
      ref_1 = create_file_ref
      spy = create_spy
      select(ref_1).all(&spy.block)
      expect(spy.called?).to eql(true)
    end

    it "yields all FileRefs to the block" do
      refs = [create_file_ref, create_file_ref, create_file_ref]
      select(*refs).all do |file_refs|
        expect(file_refs.count).to eql(3)
        expect(file_refs.map(&:path)).to match_array(refs.map(&:path))
      end
    end

    it "has no effect when no block is given" do
      expect(->{select().all}).to_not raise_error
    end
  end

  describe "#all chained" do
    let(:refs) {[
      create_file_ref(path: "/example/path/document.txt"),
      create_file_ref(path: "/example/dir/text.doc"),
      create_file_ref(path: "/sample/path/document.txt")
    ]}

    it "yields with results from a previous selection" do
      spy = create_spy
      select(*refs).with_path("/example").all(&spy.block)
      expect(spy.yielded[0].count).to eql(2)
      expect(spy.yielded[0]).to match_array([refs[0], refs[1]])
    end

    it "does not yield when no FileRefs match a previous selector" do
      ref_1 = create_file_ref(path: "/example/file.txt")
      spy = create_spy
      select(ref_1).with_path("does-not-exist").all(&spy.block)
      expect(spy.called?).to eql(false)
    end
  end
end
