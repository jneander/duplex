module Duplex
  module Datastore
    class Factory
      def get_datastore(path)
        Duplex::Datastore::FlatFile.new(path)
      end
    end
  end
end
