require "duplex/file_ref"
require "duplex/filestore/base"

module Duplex
  module Filestore
    class Memory < Filestore::Base
      def initialize(root)
        super(root)
        @files = []
        @paths = []
      end

      def move_file(file_ref, target_path)
        index = @files.index {|ref| ref.path == file_ref.path}
        raise unless index
        moved = @files[index] = clone_to_path(@files[index], full_path(target_path))
        add_subpaths(moved.location)
        moved
      end

      def add_file(file_ref)
        @files << file_ref.dup
        add_subpaths(file_ref.location)
        file_ref
      end

      def entries(path)
        path_from_root = full_path(path)
        files = @files.select {|file_ref| file_ref.location == path_from_root}.map(&:path)
        paths = @paths.select {|path_ref| path_ref.location == path_from_root}.map(&:path)
        files + paths
      end

      def nested_entries(path)

      end

      def assign_sha(file_ref)
        file_ref.sha ||= Digest::SHA1.hexdigest(file_ref.path)
      end

      private

      def add_subpaths(location)
        ref = PathRef.new(location)
        (@paths << ref).uniq!
        add_subpaths(ref.location) unless ref.location == location
      end

      class PathRef
        attr_reader :path, :name, :location

        def initialize(path)
          @path = clean_path(path)
          @location = File.dirname(@path).to_s
          @name = File.basename(@path).to_s
        end

        private

        def clean_path(path)
          Pathname.new(path).cleanpath.to_path.to_s
        end
      end
    end
  end
end
