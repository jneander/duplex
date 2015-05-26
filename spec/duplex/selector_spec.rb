require "spec_helper"

describe Duplex::Selector do
  def create_with_file_refs(*refs)
    Duplex::Selector.new(refs)
  end

  describe "#with_path" do
    let(:location_1) { "/example_path" }
    let(:location_2) { "/sample_path" }

    it "divides FileRefs using the given path" do
      ref_1 = create_file_ref(location: location_1)
      ref_2 = create_file_ref(location: location_1)
      ref_3 = create_file_ref(location: location_2)
      selector = create_with_file_refs(ref_1, ref_2, ref_3).with_path("/example_path")
      expect(selector.to_a).to match_array([ref_1, ref_2])
      expect(selector.rejected).to eql([ref_3])
    end

    it "matches with nested paths" do
      ref_1 = create_file_ref(location: location_1)
      ref_2 = create_file_ref(location: location_2)
      selector = create_with_file_refs(ref_1, ref_2).with_path("ample_path")
      expect(selector.to_a).to match_array([ref_1, ref_2])
      expect(selector.rejected).to eql([])
    end

    it "accepts regular expressions" do
      ref_1 = create_file_ref(location: location_1)
      ref_2 = create_file_ref(location: location_1)
      ref_3 = create_file_ref(location: location_2)
      selector = create_with_file_refs(ref_1, ref_2, ref_3).with_path(/example_path/)
      expect(selector.to_a).to match_array([ref_1, ref_2])
      expect(selector.rejected).to eql([ref_3])
    end

    it "can use regular expressions for greater precision" do
      ref_1 = create_file_ref(location: "/example_path")
      ref_2 = create_file_ref(location: "/nested/example_path")
      selector = create_with_file_refs(ref_1, ref_2).with_path(/^\/example_path/)
      expect(selector.to_a).to match_array([ref_1])
      expect(selector.rejected).to eql([ref_2])
    end
  end

  describe "#with_name" do
    let(:name_1) { "example_name" }
    let(:name_2) { "sample_name" }

    it "divides FileRefs using the given name" do
      ref_1 = create_file_ref(name: name_1)
      ref_2 = create_file_ref(name: name_1)
      ref_3 = create_file_ref(name: name_2)
      selector = create_with_file_refs(ref_1, ref_2, ref_3).with_name("example_name")
      expect(selector.to_a).to match_array([ref_1, ref_2])
      expect(selector.rejected).to eql([ref_3])
    end

    it "matches with partial names" do
      ref_1 = create_file_ref(name: name_1)
      ref_2 = create_file_ref(name: name_2)
      selector = create_with_file_refs(ref_1, ref_2).with_name("ample_name")
      expect(selector.to_a).to match_array([ref_1, ref_2])
      expect(selector.rejected).to eql([])
    end

    it "accepts regular expressions" do
      ref_1 = create_file_ref(name: name_1)
      ref_2 = create_file_ref(name: name_1)
      ref_3 = create_file_ref(name: name_2)
      selector = create_with_file_refs(ref_1, ref_2, ref_3).with_name(/example_name/)
      expect(selector.to_a).to match_array([ref_1, ref_2])
      expect(selector.rejected).to eql([ref_3])
    end

    it "can use regular expressions for greater precision" do
      ref_1 = create_file_ref(name: "example_name")
      ref_2 = create_file_ref(name: "other_example_name")
      selector = create_with_file_refs(ref_1, ref_2).with_name(/^example_name/)
      expect(selector.to_a).to match_array([ref_1])
      expect(selector.rejected).to eql([ref_2])
    end
  end

  describe "#with_ext" do
    let(:ext_1) { ".jpg" }
    let(:ext_2) { ".png" }

    it "divides FileRefs using the given extension" do
      ref_1 = create_file_ref(ext: ext_1)
      ref_2 = create_file_ref(ext: ext_1)
      ref_3 = create_file_ref(ext: ext_2)
      selector = create_with_file_refs(ref_1, ref_2, ref_3).with_ext(ext_1)
      expect(selector.to_a).to match_array([ref_1, ref_2])
      expect(selector.rejected).to eql([ref_3])
    end

    it "matches without a dot" do
      ref_1 = create_file_ref(ext: ext_1)
      selector = create_with_file_refs(ref_1).with_ext(ext_1.delete("."))
      expect(selector.to_a).to match_array([ref_1])
      expect(selector.rejected).to eql([])
    end
  end

  describe "#with_sha" do
    let(:sha_1) { "da39a3ee5e6b4b0d3255bfef95601890afd80709" }
    let(:sha_2) { "adc83b19e793491b1c6ea0fd8b46cd9f32e592fc" }

    it "divides FileRefs using the given sha" do
      ref_1 = create_file_ref(sha: sha_1)
      ref_2 = create_file_ref(sha: sha_1)
      ref_3 = create_file_ref(sha: sha_2)
      selector = create_with_file_refs(ref_1, ref_2, ref_3).with_sha(sha_1)
      expect(selector.to_a).to match_array([ref_1, ref_2])
      expect(selector.rejected).to eql([ref_3])
    end

    it "matches only exact shas" do
      ref_1 = create_file_ref(sha: sha_1)
      ref_2 = create_file_ref(sha: sha_2)
      selector = create_with_file_refs(ref_1, ref_2).with_sha(sha_1[0...-1])
      expect(selector.to_a).to match_array([])
      expect(selector.rejected).to eql([ref_1, ref_2])
    end
  end

  describe "#with_size" do
    it "divides FileRefs using the given size" do
      ref_1 = create_file_ref(size: 123)
      ref_2 = create_file_ref(size: 123)
      ref_3 = create_file_ref(size: 1234)
      selector = create_with_file_refs(ref_1, ref_2, ref_3).with_size(123)
      expect(selector.to_a).to match_array([ref_1, ref_2])
      expect(selector.rejected).to eql([ref_3])
    end

    it "compares with a range when given two values" do
      ref_1 = create_file_ref(size: 122)
      ref_2 = create_file_ref(size: 123)
      ref_3 = create_file_ref(size: 456)
      ref_4 = create_file_ref(size: 457)
      selector = create_with_file_refs(ref_1, ref_2, ref_3, ref_4).with_size(123, 456)
      expect(selector.to_a).to match_array([ref_2, ref_3])
      expect(selector.rejected).to eql([ref_1, ref_4])
    end

    it "uses an infinite range when second value is '-1'" do
      ref_1 = create_file_ref(size: 122)
      ref_2 = create_file_ref(size: 123)
      ref_3 = create_file_ref(size: 456)
      selector = create_with_file_refs(ref_1, ref_2, ref_3).with_size(123, -1)
      expect(selector.to_a).to match_array([ref_2, ref_3])
      expect(selector.rejected).to eql([ref_1])
    end
  end
end
