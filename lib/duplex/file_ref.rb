module Duplex
  class FileRef
    InvalidPath = Class.new(ArgumentError)

    attr_reader :path, :name, :location, :ext
    attr_accessor :sha, :size

    def initialize(attr)
      @path = clean_path(attr[:path])
      @location = File.dirname(@path)
      @name = File.basename(@path).to_s
      @ext = File.extname(@path)
      @sha = attr[:sha]
      @size = attr[:size]
    end

    def to_hash
      {
        path: @path,
        sha:  @sha,
        size: @size
      }
    end

    private

    def clean_path(path)
      Pathname.new(path).cleanpath.to_path
    end
  end
end
