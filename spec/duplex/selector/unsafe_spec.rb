require "spec_helper"

describe Duplex::Selector::Unsafe do
  def select(*refs)
    Duplex::Selector::Unsafe.new(refs)
  end

  describe "#with_path" do
    it_behaves_like "Selector #with_path"

    it "yields an empty array when no FileRefs match" do
      ref_1 = create_file_ref(location: "/example_path")
      select(ref_1).with_path("does-not-exist") do |included, excluded|
        expect(included).to match_array([])
        expect(excluded).to eql([ref_1])
      end
    end
  end

  describe "#with_path chained" do
    it_behaves_like "Selector #with_path chained"
  end

  describe "#with_name" do
    it_behaves_like "Selector #with_name"

    it "yields an empty array when no FileRefs match" do
      ref_1 = create_file_ref(name: "example")
      select(ref_1).with_name("does-not-exist") do |included, excluded|
        expect(included).to match_array([])
        expect(excluded).to eql([ref_1])
      end
    end
  end

  describe "#with_name chained" do
    it_behaves_like "Selector #with_name chained"
  end

  describe "#with_ext" do
    it_behaves_like "Selector #with_ext"

    it "yields an empty array when no FileRefs match" do
      ref_1 = create_file_ref(ext: "txt")
      select(ref_1).with_ext("dne") do |included, excluded|
        expect(included).to match_array([])
        expect(excluded).to eql([ref_1])
      end
    end
  end

  describe "#with_ext chained" do
    it_behaves_like "Selector #with_ext chained"
  end

  describe "#with_sha" do
    it_behaves_like "Selector #with_sha"

    it "yields an empty array when no FileRefs match" do
      ref_1 = create_file_ref(sha: "ABC123")
      select(ref_1).with_sha("doesnotexist") do |included, excluded|
        expect(included).to match_array([])
        expect(excluded).to eql([ref_1])
      end
    end
  end

  describe "#with_sha chained" do
    it_behaves_like "Selector #with_sha chained"
  end

  describe "#with_size" do
    it_behaves_like "Selector #with_size"

    it "yields an empty array when no FileRefs match" do
      ref_1 = create_file_ref(size: 123)
      select(ref_1).with_size(456) do |included, excluded|
        expect(included).to match_array([])
        expect(excluded).to eql([ref_1])
      end
    end
  end

  describe "#with_size chained" do
    it_behaves_like "Selector #with_size chained"
  end

  describe "#with_uniq_name" do
    it_behaves_like "Selector #with_uniq_name"

    it "yields an empty array when FileRefs have different names" do
      ref_1 = create_file_ref(path: "/example/1/name_1.txt")
      ref_2 = create_file_ref(path: "/example/2/name_1.txt")
      ref_3 = create_file_ref(path: "/example/3/name_2.txt")
      select(ref_1, ref_2, ref_3).with_uniq_name do |included, excluded|
        expect(included).to match_array([])
        expect(excluded).to eql([ref_1, ref_2, ref_3])
      end
    end
  end

  describe "#with_uniq_name chained" do
    it_behaves_like "Selector #with_uniq_name chained"
  end

  describe "#with_uniq_location" do
    it_behaves_like "Selector #with_uniq_location"

    it "yields an empty array when FileRefs have different locations" do
      ref_1 = create_file_ref(location: "/example/1")
      ref_2 = create_file_ref(location: "/example/1")
      ref_3 = create_file_ref(location: "/example/2")
      select(ref_1, ref_2, ref_3).with_uniq_location do |included, excluded|
        expect(included).to match_array([])
        expect(excluded).to eql([ref_1, ref_2, ref_3])
      end
    end
  end

  describe "#with_uniq_location chained" do
    it_behaves_like "Selector #with_uniq_location chained"
  end

  describe "#each" do
    it_behaves_like "Selector #each"

    it "does not yield when no FileRefs have been stored" do
      yielded = []
      select().each do |file_ref|
        yielded << file_ref
      end
      expect(yielded).to be_empty
    end
  end

  describe "#each chained" do
    it_behaves_like "Selector #each chained"
  end

  describe "#all" do
    it_behaves_like "Selector #all"

    it "yields an empty array when no FileRefs have been stored" do
      select().all do |file_refs|
        expect(file_refs).to be_empty
      end
    end
  end

  describe "#all chained" do
    it_behaves_like "Selector #all chained"
  end
end
