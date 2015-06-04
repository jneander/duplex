require "pathname"

module Duplex
  class FileRef
    InvalidPath = Class.new(ArgumentError)

    attr_reader :path, :name, :location, :ext
    attr_accessor :sha, :size, :destination, :decision

    def initialize(attr)
      @path = clean_path(attr[:path])
      @location = File.dirname(@path)
      @name = File.basename(@path).to_s
      @ext = File.extname(@path)
      @sha = attr[:sha]
      @size = attr[:size]
      @destination = attr[:destination]
      @decision = attr[:decision]
    end

    def to_hash
      {
        path:        @path,
        sha:         @sha,
        size:        @size,
        destination: @destination,
        decision:    @decision
      }
    end

    def eql?(file_ref)
      path == file_ref.path
    end

    private

    def clean_path(path)
      Pathname.new(path).cleanpath.to_path
    end
  end
end
