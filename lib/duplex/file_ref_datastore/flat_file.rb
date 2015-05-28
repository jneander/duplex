require "fileutils"

require "duplex/file_ref"
require "duplex/file_ref_datastore/base"
require "duplex/file_ref_datastore/memory"

module Duplex
  module FileRefDatastore
    class FlatFile < FileRefDatastore::Base
      extend Forwardable

      def_delegators :@cache, :create!, :update_path!, :destroy_all!
      def_delegators :@cache, :find_in_path, :find_by_path_fragment
      def_delegators :@cache, :to_a, :count

      def initialize(file_path)
        @file_path = file_path
        @cache = FileRefDatastore::Memory.new
        @cache.add_file_refs(load_file)
      end

      def save!
        FileUtils.mkdir_p(File.dirname(@file_path))
        tmp_path = @file_path + ".tmp"
        File.open(tmp_path, "w+") do |file|
          Marshal.dump(to_file, file)
        end
        FileUtils.mv(tmp_path, @file_path)
      end

      private

      def to_file
        @cache.to_a.map(&:to_hash)
      end

      def load_file
        return [] unless File.exists?(@file_path)
        File.open(@file_path) {|file| Marshal.load(file)}.map {|attr| FileRef.new(attr)}
      end
    end
  end
end
