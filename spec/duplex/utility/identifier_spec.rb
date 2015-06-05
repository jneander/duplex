require "spec_helper"

describe Duplex::Identifier do
  def identify(*refs)
    Duplex::Identifier.new(refs)
  end

  let(:small_1) { create_file_ref(size: 123, sha: "smallExampleSha") }
  let(:small_2) { create_file_ref(size: 123, sha: "smallExampleSha") }
  let(:small_3) { create_file_ref(size: 123, sha: "smallSampleSha") }
  let(:small_4) { create_file_ref(size: 234, sha: "smallSampleSha") }
  let(:large_1) { create_file_ref(size: 789, sha: "largeExampleSha") }
  let(:large_2) { create_file_ref(size: 789, sha: "largeExampleSha") }
  let(:large_3) { create_file_ref(size: 789, sha: "largeSampleSha") }
  let(:large_4) { create_file_ref(size: 789, sha: "largeSampleSha") }
  let(:partial_1) { create_file_ref(size: 123, sha: nil) }
  let(:partial_2) { create_file_ref(size: 123, sha: nil) }
  let(:partial_3) { create_file_ref(size: 234, sha: nil) }
  let(:partial_4) { create_file_ref(size: nil, sha: "smallExampleSha") }
  let(:partial_5) { create_file_ref(size: nil, sha: "smallExampleSha") }
  let(:partial_6) { create_file_ref(size: nil, sha: "smallSampleSha") }
  let(:incomplete_1) { create_file_ref(size: nil, sha: nil) }
  let(:incomplete_2) { create_file_ref(size: nil, sha: nil) }

  describe "#duplicates" do
    it "groups FileRefs with unique sizes and matching shas" do
      identifier = identify(large_1, large_2, large_3, large_4)
      expect(identifier.duplicates.count).to eql(2)
      expect(identifier.duplicates[0]).to match_array([large_1, large_2])
      expect(identifier.duplicates[1]).to match_array([large_3, large_4])
    end

    it "groups FileRefs with matching sizes and matching shas" do
      identifier = identify(small_1, small_2, large_1, large_2)
      expect(identifier.duplicates.count).to eql(2)
      expect(identifier.duplicates[0]).to match_array([small_1, small_2])
      expect(identifier.duplicates[1]).to match_array([large_1, large_2])
    end

    it "excludes FileRefs with unique sizes and unique shas" do
      identifier = identify(small_1, small_2, small_4)
      expect(identifier.duplicates.count).to eql(1)
      expect(identifier.duplicates[0]).to match_array([small_1, small_2])
    end

    it "excludes FileRefs with unique sizes and missing shas" do
      identifier = identify(large_1, large_2, partial_2, partial_3)
      expect(identifier.duplicates.count).to eql(1)
      expect(identifier.duplicates[0]).to match_array([large_1, large_2])
    end

    it "excludes FileRefs with matching sizes and unique shas" do
      identifier = identify(small_1, small_2, large_2, large_3)
      expect(identifier.duplicates.count).to eql(1)
      expect(identifier.duplicates[0]).to match_array([small_1, small_2])
    end

    it "excludes FileRefs with matching sizes and missing shas" do
      identifier = identify(large_1, large_2, partial_1, partial_2)
      expect(identifier.duplicates.count).to eql(1)
      expect(identifier.duplicates[0]).to match_array([large_1, large_2])
    end

    it "excludes FileRefs with missing sizes and unique shas" do
      identifier = identify(large_1, large_2, partial_5, partial_6)
      expect(identifier.duplicates.count).to eql(1)
      expect(identifier.duplicates[0]).to match_array([large_1, large_2])
    end

    it "groups FileRefs with missing sizes and matching shas" do
      identifier = identify(small_1, small_2, partial_4, partial_5)
      expect(identifier.duplicates.count).to eql(1)
      expect(identifier.duplicates[0]).to match_array([small_1, small_2, partial_4, partial_5])
    end

    it "excludes all FileRefs when any have no :size or :sha" do
      identifier = identify(small_1, small_2, incomplete_1)
      expect(identifier.duplicates.count).to eql(0)
    end

    it "excludes partial matches when some FileRefs are incomplete" do
      identifier = identify(small_1, small_2, partial_1, partial_2)
      expect(identifier.duplicates.count).to eql(0)
    end
  end

  describe "#unique" do
    it "includes FileRefs with unique sizes and unique shas" do
      identifier = identify(small_1, small_4, large_1)
      expect(identifier.unique.count).to eql(3)
      expect(identifier.unique).to match_array([small_1, small_4, large_1])
    end

    it "excludes FileRefs with unique sizes and matching shas" do
      identifier = identify(small_3, small_4)
      expect(identifier.unique.count).to eql(0)
    end

    it "includes FileRefs with unique sizes and missing shas" do
      identifier = identify(partial_1, small_4, large_1, large_3)
      expect(identifier.unique.count).to eql(4)
      expect(identifier.unique).to match_array([partial_1, small_4, large_1, large_3])
    end

    it "includes FileRefs with matching sizes and unique shas" do
      identifier = identify(small_1, small_4, large_1, large_3)
      expect(identifier.unique.count).to eql(4)
      expect(identifier.unique).to match_array([small_1, small_4, large_1, large_3])
    end

    it "excludes FileRefs with matching sizes and matching shas" do
      identifier = identify(small_1, small_4, large_1, large_2)
      expect(identifier.unique.count).to eql(2)
      expect(identifier.unique).to match_array([small_1, small_4])
    end

    it "excludes FileRefs with matching sizes and missing shas" do
      identifier = identify(partial_1, partial_2, large_1, large_3)
      expect(identifier.unique.count).to eql(2)
      expect(identifier.unique).to match_array([large_1, large_3])
    end

    it "excludes FileRefs with missing sizes and unique shas" do
      identifier = identify(partial_5, partial_6)
      expect(identifier.unique.count).to eql(2)
      expect(identifier.unique).to match_array([partial_5, partial_6])
    end

    it "excludes FileRefs with missing sizes and matching shas" do
      identifier = identify(large_1, large_3, partial_4, partial_5)
      expect(identifier.unique.count).to eql(2)
      expect(identifier.unique).to match_array([large_1, large_3])
    end

    it "excludes partial matches when some FileRefs are incomplete" do
      identifier = identify(small_1, partial_1)
      expect(identifier.unique.count).to eql(0)
    end

    it "excludes all FileRefs when any have no :size or :sha" do
      identifier = identify(small_1, large_1, incomplete_1)
      expect(identifier.unique.count).to eql(0)
    end
  end

  describe "#incomplete" do
    it "excludes FileRefs with unique sizes and unique shas" do
      identifier = identify(small_1, small_4, large_1)
      expect(identifier.incomplete.count).to eql(0)
    end

    it "excludes FileRefs with unique sizes and matching shas" do
      identifier = identify(small_3, small_4)
      expect(identifier.incomplete.count).to eql(0)
    end

    it "excludes FileRefs with unique sizes and missing shas" do
      identifier = identify(partial_1, partial_3)
      expect(identifier.incomplete.count).to eql(0)
    end

    it "excludes FileRefs with matching sizes and unique shas" do
      identifier = identify(small_2, small_3, large_2, large_3)
      expect(identifier.incomplete.count).to eql(0)
    end

    it "excludes FileRefs with matching sizes and matching shas" do
      identifier = identify(small_1, small_2, large_1, large_2)
      expect(identifier.incomplete.count).to eql(0)
    end

    it "includes FileRefs with matching sizes and missing shas" do
      identifier = identify(partial_1, partial_2)
      expect(identifier.incomplete.count).to eql(2)
      expect(identifier.incomplete).to match_array([partial_1, partial_2])
    end

    it "excludes FileRefs with missing sizes and unique shas" do
      identifier = identify(partial_5, partial_6)
      expect(identifier.incomplete.count).to eql(0)
    end

    it "excludes FileRefs with missing sizes and matching shas" do
      identifier = identify(partial_4, partial_5)
      expect(identifier.incomplete.count).to eql(0)
    end

    it "includes FileRefs with missing sizes and missing shas" do
      identifier = identify(small_1, large_1, incomplete_1)
      expect(identifier.incomplete.count).to eql(1)
      expect(identifier.incomplete).to match_array([incomplete_1])
    end

    it "includes partial matches when some FileRefs are incomplete" do
      identifier = identify(small_1, small_4, partial_1, partial_2, partial_3)
      expect(identifier.incomplete.count).to eql(3)
      expect(identifier.incomplete).to match_array([partial_1, partial_2, partial_3])
    end

    it "includes FileRefs with no :size when any have no :size or :sha" do
      identifier = identify(partial_4, partial_6, incomplete_1)
      expect(identifier.incomplete.count).to eql(3)
      expect(identifier.incomplete).to match_array([partial_4, partial_6, incomplete_1])
    end

    it "includes all FileRefs when none have :size or :sha" do
      identifier = identify(incomplete_1, incomplete_2)
      expect(identifier.incomplete.count).to eql(2)
      expect(identifier.incomplete).to match_array([incomplete_1, incomplete_2])
    end
  end
end
