require "duplex/file_ref"
require "duplex/datastore/base"

module Duplex
  module Datastore
    class Memory < Datastore::Base
      def initialize
        @file_refs = []
        @saved = true
      end

      def create!(attr)
        validate_path(attr[:path])
        ref = FileRef.new(attr)
        to_a << ref
        @saved = false
        ref.dup
      end

      def update(file_ref, attrs)
        validate_path(attrs[:path]) if attrs.include?(:path)
        validate_path(attrs[:destination]) if attrs.include?(:destination)
        exchange(file_ref, FileRef.new(file_ref.to_hash.merge(attrs)))
        @saved = false
      end

      def find_by_path(path)
        found = to_a.detect {|file| file.path == path}
        found.dup if found
      end

      def find_all_by_path(path)
        to_a.select {|file| file.path.index(path)}.map(&:dup)
      end

      def add_file_refs(file_refs)
        @file_refs.concat(file_refs.map(&:dup)).uniq!(&:path)
        @saved = false
      end

      def destroy_all!
        @file_refs = []
        @saved = false
      end

      def save!
        @saved = true
      end

      def unsaved_changes?
        !@saved
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
