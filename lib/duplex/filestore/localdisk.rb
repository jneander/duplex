require "fileutils"

require "duplex/file_ref"
require "duplex/filestore/base"

module Duplex
  module Filestore
    class Localdisk < Filestore::Base
      def move_file(file_ref, target_path)
        full_target = full_path(target_path)
        FileUtils.mkdir_p(File.dirname(full_target))
        FileUtils.mv(file_ref.path, full_target)
        FileRef.new(path: full_target)
      end

      def entries(path)
        return [] unless Dir.exists?(full_path(path))
        path_entries(full_path(path))
      end

      def nested_files(path)
        return [] unless Dir.exists?(full_path(path))
        deep_entries(full_path(path))
      end

      def assign_sha(file_ref)
        file_ref.sha ||= Digest::SHA1.file(file_ref.path).hexdigest
      end

      def assign_size(file_ref)
        file_ref.size ||= File.size(file_ref.path)
      end

      def file_exists?(file_ref)
        File.exists?(file_ref.path)
      end

      private

      def path_entries(path)
        _entries = Dir.entries(path) - [".", ".."]
        _entries.map {|entry| File.realdirpath(entry, path)}
      end

      def deep_entries(path)
        full_paths = path_entries(path)
        shallow_files = full_paths.select {|entry| File.file?(entry)}
        deep_files = (full_paths - shallow_files).map {|path| deep_entries(path)}
        shallow_files + deep_files.flatten
      end
    end
  end
end
