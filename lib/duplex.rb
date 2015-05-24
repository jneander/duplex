require "duplex/version"
require "duplex/filestore/memory"
require "duplex/filestore/localdisk"
require "duplex/file_ref_datastore/memory"
require "duplex/file_ref_datastore/flat_file"

module Duplex
  class Duplexer
    def initialize(config)
      @file_ref_datastore = config[:file_ref_datastore]
      @filestore = config[:filestore]
    end

    def relocate(from, to)

    end
  end
end
