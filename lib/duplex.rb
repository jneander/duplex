require "duplex/version"
require "duplex/selector"
require "duplex/filestore/memory"
require "duplex/filestore/localdisk"
require "duplex/datastore/memory"
require "duplex/datastore/flat_file"

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
    end

    def unique
      # optional block for 'all'
      # returns something with 'each'
    end

    def missing
      @datastore.to_a.each do |file_ref|
        yield file_ref unless @filestore.file_exists?(file_ref)
      end
    end

    # Decision-making

    def prefer(file_refs)
    end

    def reject(file_refs)
    end

    def select_any_one(file_refs)
      # select the first, reject the rest
    end

    # Stateful Actions on FileRefs

    def add_from_path(path)
      ## ADDING FILES
      # Alternatives: deep/shallow; regex; glob
      # add_files(DataList, glob, regex)
    end

    def add_from_datastore(datastore)
      @datastore.add_file_refs(datastore.to_a)
    end

    def drop(file_refs)
    end

    def drop!(file_refs)
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

    def current_selector
    end
  end
end
