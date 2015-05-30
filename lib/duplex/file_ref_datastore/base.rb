module Duplex
  module FileRefDatastore
    DuplicatePath = Class.new(ArgumentError)
    NotFound = Class.new(ArgumentError)

    class Base
      def save!
      end

      private

      def valid_path?(path)
        !!path
      end

      def validate_path(path)
        raise FileRef::InvalidPath.new(path) unless valid_path?(path)
        raise DuplicatePath.new(path) if to_a.any? do |file|
          file.path == path || file.destination == path
        end
      end
    end
  end
end
