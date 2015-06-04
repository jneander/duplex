require "fileutils"
require "forwardable"

require "duplex/file_ref"
require "duplex/datastore/base"
require "duplex/datastore/memory"

module Duplex
  module Datastore
    class FlatFile < Datastore::Base
      extend Forwardable

      def_delegators :@cache, :create!, :update, :destroy_all!
      def_delegators :@cache, :add_file_refs
      def_delegators :@cache, :find_by_path, :find_all_by_path
      def_delegators :@cache, :to_a, :count, :unsaved_changes?

      def initialize(file_path)
        @file_path = file_path
        @cache = Datastore::Memory.new
        @cache.add_file_refs(load_file)
      end

      def save!
        FileUtils.mkdir_p(File.dirname(@file_path))
        tmp_path = @file_path + ".tmp"
        File.open(tmp_path, "w+") do |file|
          Marshal.dump(to_file, file)
        end
        FileUtils.mv(tmp_path, @file_path)
        @cache.save!
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
