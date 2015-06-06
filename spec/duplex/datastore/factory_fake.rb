module Duplex
  module Datastore
    class FactoryFake
      def get_datastore(path)
        @datastore || Duplex::Datastore::Memory.new(path)
      end

      def set_datastore(datastore)
        @datastore = datastore
      end
    end
  end
end
