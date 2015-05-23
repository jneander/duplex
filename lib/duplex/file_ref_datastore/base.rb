module Duplex
  module FileRefDatastore
    DuplicatePath = Class.new(ArgumentError)
    NotFound = Class.new(ArgumentError)

    class Base
      private

      def valid_path?(path)
        !!path
      end

      def validate_path(path)
        raise DuplicatePath.new(path) if @file_refs.any? {|file| file.path == path}
        raise FileRef::InvalidPath.new(path) unless valid_path?(path)
      end
    end
  end
end
