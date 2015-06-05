module Duplex
  class Duplexer
    def initialize(config)
      @datastore = config[:datastore]
      @filestore = config[:filestore]
    end

    # FileRef Selection

    def all
      Selector.new(@datastore.to_a)
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
      Selector.new(@datastore.to_a.reject {|file_ref|
        @filestore.file_exists?(file_ref)
      })
    end

    # Decision-making

    def keep(file_refs)
      file_refs.each do |file_ref|
        next unless @datastore.exists?(file_ref)
        @datastore.update(file_ref, decision: :keep)
        file_ref.decision = :keep
      end
    end

    def prefer(file_refs)
      file_refs.each do |file_ref|
        next unless @datastore.exists?(file_ref)
        @datastore.update(file_ref, decision: :prefer)
        file_ref.decision = :prefer
      end
    end

    def remove(file_refs)
      file_refs.each do |file_ref|
        next unless @datastore.exists?(file_ref)
        @datastore.update(file_ref, decision: :remove)
        file_ref.decision = :remove
      end
    end

    def drop(file_refs)
    end

    # Stateful Actions on FileRefs

    def add_from_path(path)
      import.from_path(path)
    end

    def add_from_datastore(datastore)
      @datastore.add_file_refs(datastore.to_a)
    end

    def relocate(file_refs, from, to)
      file_refs.each do |file_ref|
        next unless file_ref.path.index(from)
        @datastore.update(file_ref, {destination: file_ref.path.gsub(from, to)})
      end
    end

    # Stateful Actions on the Datastore

    def save!
      @datastore.save!
    end

    def commit!
    end

    # Output

    def export_data_list
    end

    def export_plain_text
    end

    def report
    end

    private

    def identify
      Identifier.new(@datastore.to_a)
    end

    def import
      FileImport.new(datastore: @datastore, filestore: @filestore)
    end
  end
end
