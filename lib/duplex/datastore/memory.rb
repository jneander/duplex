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
        validate_create_attrs(attr)
        ref = FileRef.new(attr)
        to_a << ref
        @saved = false
        ref.dup
      end

      def update(file_ref, attrs)
        validate_update_attrs(file_ref, attrs)
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

      def destroy(file_refs)
        paths = file_refs.map(&:path)
        @file_refs.reject! {|file_ref| paths.include?(file_ref.path)}
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

      def exists?(file_ref)
        to_a.any? {|ref| ref.path == file_ref.path}
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
        to_a[index] = updated
      end
    end
  end
end
