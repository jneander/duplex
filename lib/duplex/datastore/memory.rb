require "duplex/file_ref"
require "duplex/datastore/base"

module Duplex
  module Datastore
    class Memory < Datastore::Base
      def initialize
        @file_refs = []
      end

      def create!(attr)
        validate_path(attr[:path])
        ref = FileRef.new(attr)
        to_a << ref
        ref.dup
      end

      def update(file_ref, attrs)
        validate_path(attrs[:path]) if attrs.include?(:path)
        validate_path(attrs[:destination]) if attrs.include?(:destination)
        exchange(file_ref, FileRef.new(file_ref.to_hash.merge(attrs)))
      end

      def find_by_path(path)
        found = to_a.detect {|file| file.path == path}
        found.dup if found
      end

      def find_all_by_path(path)
        to_a.select {|file| file.path.index(path)}.map(&:dup)
      end

      def update_path!(file_ref, path)
        validate_path(path)
        updated_attr = file_ref.to_hash.merge({path: path})
        exchange(file_ref, FileRef.new(updated_attr))
      end

      def add_file_refs(file_refs)
        @file_refs.concat(file_refs.map(&:dup)).uniq!(&:path)
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
