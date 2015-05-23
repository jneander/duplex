require "digest"

module Duplex
  module Filestore
    class Base
      def initialize(root)
        @root = root
      end

      private

      def full_path(path)
        File.expand_path(File.join(@root, path))
      end

      def clone_to_path(file_ref, path)
        FileRef.new(file_ref.to_hash.merge(path: path))
      end
    end
  end
end
