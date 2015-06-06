module Duplex
  module Datastore
    DuplicatePath = Class.new(ArgumentError)
    NotFound = Class.new(ArgumentError)

    class Base
      attr_reader :path

      private

      def validate_create_attrs(attrs)
        path, destination = attrs.values_at(:path, :destination)

        raise FileRef::InvalidPath.new(path) if !valid_path?(path)

        validate_unused_path(to_a, path) if path
        validate_unused_path(to_a, destination) if destination
      end

      def validate_update_attrs(file_ref, attrs)
        path, destination = attrs.values_at(:path, :destination)

        raise FileRef::InvalidPath.new(path) if attrs.include?(:path) && !valid_path?(path)
        raise NotFound.new(file_ref.path) unless stored = find_by_path(file_ref.path)

        other_refs = to_a.reject {|file| file.path == file_ref.path}

        validate_unused_path(other_refs, path) if path && stored.path != path
        validate_unused_path(other_refs, destination) if destination && stored.destination != destination
      end

      def valid_path?(path)
        !!path
      end

      def validate_unused_path(file_refs, path)
        raise DuplicatePath.new(path) if file_refs.any? do |file|
          file.path == path || file.destination == path
        end
      end
    end
  end
end
