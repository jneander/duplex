require "spec_helper"

describe Duplex::FileRef do
  describe "#eql?" do
    it "returns true when both FileRefs have the same data" do
      file_ref_1 = Duplex::FileRef.new(path: "/path/A/file.txt")
      file_ref_2 = Duplex::FileRef.new(path: "/path/A/file.txt")
      expect(file_ref_1.eql?(file_ref_2)).to eql(true)
      expect(file_ref_2.eql?(file_ref_1)).to eql(true)
    end

    it "returns false when the FileRefs have different locations" do
      file_ref_1 = Duplex::FileRef.new(path: "/path/A/file.txt")
      file_ref_2 = Duplex::FileRef.new(path: "/path/B/file.txt")
      expect(file_ref_1.eql?(file_ref_2)).to eql(false)
      expect(file_ref_2.eql?(file_ref_1)).to eql(false)
    end

    it "returns false when the FileRefs have different filenames" do
      file_ref_1 = Duplex::FileRef.new(path: "/path/file_A.txt")
      file_ref_2 = Duplex::FileRef.new(path: "/path/file_B.txt")
      expect(file_ref_1.eql?(file_ref_2)).to eql(false)
      expect(file_ref_2.eql?(file_ref_1)).to eql(false)
    end

    it "returns false when the FileRefs have different extensions" do
      file_ref_1 = Duplex::FileRef.new(path: "/path/file.txt")
      file_ref_2 = Duplex::FileRef.new(path: "/path/file.doc")
      expect(file_ref_1.eql?(file_ref_2)).to eql(false)
      expect(file_ref_2.eql?(file_ref_1)).to eql(false)
    end
  end
end
