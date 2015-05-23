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

      def nested_entries(path)

      end

      def assign_sha(file_ref)
        file_ref.sha ||= Digest::SHA1.file(file_ref.path).hexdigest
      end

      private

      def path_entries(path)
        _entries = Dir.entries(path) - [".", ".."]
        _entries.map {|entry| File.realdirpath(entry, path)}
      end
    end
  end
end
