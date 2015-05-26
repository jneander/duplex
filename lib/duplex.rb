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
      @file_ref_datastore = config[:file_ref_datastore]
      @filestore = config[:filestore]
    end

    def use_list(list)
      # accept either a Duplex::DataList or file path
    end

    ## ADDING FILES
    # Alternatives: deep/shallow; regex; glob
    # add_files(DataList, glob, regex)

    def add_from_path(path)
    end

    def add_from_data_list(list)
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

    def duplicates
    end

    def report
    end

    def commit!
    end

    private

    def current_selector
    end
  end
end
