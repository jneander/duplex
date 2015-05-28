require "duplex/version"
require "duplex/selector"
require "duplex/filestore/memory"
require "duplex/filestore/localdisk"
require "duplex/file_ref_datastore/memory"
require "duplex/file_ref_datastore/flat_file"

module Duplex
  class Duplexer
    extend Forwardable

    def_delegators :current_selector, :with_path, :with_name, :with_ext, :with_sha, :with_size,

    def initialize(config)
      @datastore = config[:datastore]
      @filestore = config[:filestore]
    end

    ## ADDING FILES
    # Alternatives: deep/shallow; regex; glob
    # add_files(DataList, glob, regex)

    def add_from_path(path)
    end

    def add_from_datastore(datastore)
      @datastore.add_file_refs(datastore.to_a)
    end

    def save!
      @datastore.save!
    end

    ##

    def export_data_list
    end

    def export_plain_text
    end

    ##

    def relocate(from, to)
    end

    def missing
    end

    def all
    end

    def duplicates
    end

    def unique
      # optional block for 'all'
      # returns something with 'each'
    end

    def report
    end

    def commit!
    end

    def select_any_one(file_refs)
      # select the first, reject the rest
    end

    private

    def current_selector
    end
  end
end
