require "duplex/version"
require "duplex/datastore/memory"
require "duplex/datastore/flat_file"
require "duplex/filestore/memory"
require "duplex/filestore/localdisk"
require "duplex/utility/file_import"
require "duplex/utility/identifier"
require "duplex/utility/selector"

module Duplex
  class Duplexer
    def initialize(config)
      @datastore = config[:datastore]
      @filestore = config[:filestore]
    end

    # FileRef Selection

    def all
      @datastore.to_a.each do |file_ref|
        yield file_ref
      end
    end

    def duplicates
      identify.duplicates.each do |file_refs|
        yield Selector.new(file_refs)
      end
    end

    def unique
      Selector.new(identify.unique)
    end

    def incomplete
      identify.incomplete
    end

    def missing
      @datastore.to_a.each do |file_ref|
        yield file_ref unless @filestore.file_exists?(file_ref)
      end
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

    def keep_any_one(file_refs)
      # select the first, reject the rest
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
      @identifier ||= Identifier.new(@datastore.to_a)
    end

    def import
      @importer ||= FileImport.new(datastore: @datastore, filestore: @filestore)
    end

    def current_selector
    end
  end
end
