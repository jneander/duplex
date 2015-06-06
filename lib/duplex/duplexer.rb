module Duplex
  class Duplexer
    DatastoreNotSet = Class.new(TypeError)

    def initialize(config)
      @filestore = config[:filestore]
      @factory =   config[:datastore_factory]
    end

    # Selecting FileRefs

    def all
      Selector.new(datastore.to_a)
    end

    def duplicates
      identify.duplicates.map {|file_refs|
        Selector.new(file_refs)
      }.each
    end

    def unique
      Selector.new(identify.unique)
    end

    def incomplete
      Selector.new(identify.incomplete)
    end

    def missing
      Selector.new(datastore.to_a.reject {|file_ref|
        @filestore.file_exists?(file_ref)
      })
    end

    # Setting Decisions

    def keep(file_refs)
      file_refs.each do |file_ref|
        next unless datastore.exists?(file_ref)
        datastore.update(file_ref, decision: :keep)
        file_ref.decision = :keep
      end
    end

    def prefer(file_refs)
      file_refs.each do |file_ref|
        next unless datastore.exists?(file_ref)
        datastore.update(file_ref, decision: :prefer)
        file_ref.decision = :prefer
      end
    end

    def remove(file_refs)
      file_refs.each do |file_ref|
        next unless datastore.exists?(file_ref)
        datastore.update(file_ref, decision: :remove)
        file_ref.decision = :remove
      end
    end

    def relocate(file_refs, from, to)
      file_refs.each do |file_ref|
        next unless file_ref.path.index(from)
        datastore.update(file_ref, {destination: file_ref.path.gsub(from, to)})
      end
    end

    def drop(file_refs)
      datastore.destroy(file_refs)
    end

    # Adding FileRefs

    def add_from_path(path)
      import.from_path(path)
    end

    def add_from_datastore(_datastore)
      datastore.add_file_refs(_datastore.to_a)
    end

    # Persisting Changes

    def save!
      datastore.save!
    end

    def commit!
      datastore.to_a.select {|file_ref| file_ref.destination}.each do |file_ref|
        next unless @filestore.file_exists?(file_ref)
        @filestore.move_file(file_ref, file_ref.destination)
        datastore.update(file_ref, {path: file_ref.destination})
      end
    end

    # Managing Datastores

    def use_datastore(path)
      @datastore = @factory.get_datastore(path)
    end

    def export_to_datastore(file_refs, path)
      datastore = @factory.get_datastore(path)
      datastore.add_file_refs(file_refs)
      datastore.save!
      datastore
    end

    private

    def datastore
      @datastore or raise DatastoreNotSet.new
    end

    def identify
      Identifier.new(datastore.to_a)
    end

    def import
      FileImport.new(datastore: datastore, filestore: @filestore)
    end
  end
end
