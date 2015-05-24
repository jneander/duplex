require "duplex/file_ref"
require "duplex/file_ref_datastore/base"

module Duplex
  module FileRefDatastore
    class Memory < FileRefDatastore::Base
      def initialize
        @file_refs = []
      end

      def create!(attr)
        validate_path(attr[:path])
        ref = FileRef.new(attr)
        to_a << ref
        ref.dup
      end

      def update_path!(file_ref, path)
        validate_path(path)
        updated_attr = file_ref.to_hash.merge({path: path})
        exchange(file_ref, FileRef.new(updated_attr))
      end

      def add_file_refs(file_refs)
        @file_refs.concat(file_refs)
      end

      def find_in_path(path)
        to_a.select {|file| file.path.start_with?(path)}.map(&:dup)
      end

      def find_by_path_fragment(path)
        to_a.select {|file| file.path.include?(path)}.map(&:dup)
      end

      def destroy_all!
        @file_refs = []
      end

      def count
        to_a.count
      end

      def to_a
        @file_refs ||= []
      end

      private

      def exchange(current, updated)
        index = to_a.index {|file| file.path == current.path}
        raise NotFound.new(current.path) unless index
        validate_path(updated.path) unless current.path == updated.path
        to_a[index] = updated
      end
    end
  end
end
