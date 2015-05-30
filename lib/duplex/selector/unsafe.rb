module Duplex
  module Selector
    class Unsafe
      def initialize(file_refs)
        @matching = file_refs
        @not_matching = []
      end

      # Filters

      def with_path(pattern)
        matches = @matching.select {|ref| ref.path.index(pattern)}
        @not_matching.concat(@matching - matches)
        @matching = matches
        yield @matching, @not_matching if block_given?
        self
      end

      def with_name(pattern)
        matches = @matching.select {|ref| ref.name.index(pattern)}
        @not_matching.concat(@matching - matches)
        @matching = matches
        yield @matching, @not_matching if block_given?
        self
      end

      def with_ext(ext)
        ext = "." + ext unless ext.start_with?(".")
        matches = @matching.select {|ref| ref.ext == ext}
        @not_matching.concat(@matching - matches)
        @matching = matches
        yield @matching, @not_matching if block_given?
        self
      end

      def with_sha(string)
        matches = @matching.select {|ref| ref.sha == string}
        @not_matching.concat(@matching - matches)
        @matching = matches
        yield @matching, @not_matching if block_given?
        self
      end

      def with_size(min, max = nil)
        range = range_between(min, max || min)
        matches = @matching.select {|ref| range === ref.size}
        @not_matching.concat(@matching - matches)
        @matching = matches
        yield @matching, @not_matching if block_given?
        self
      end

      def with_uniq_name
        if @matching.uniq(&:name).count > 1
          @not_matching.concat(@matching)
          @matching = []
        end
        yield @matching, @not_matching if block_given?
        return self
      end

      def with_uniq_location
        if @matching.uniq(&:location).count > 1
          @not_matching.concat(@matching)
          @matching = []
        end
        yield @matching, @not_matching if block_given?
        return self
      end

      # Iterators

      def each(&block)
        @matching.each(&block)
      end

      def all
        yield @matching if block_given?
      end

      private

      def included_files
        # FileRefs matching
      end

      def excluded_files

      end

      def range_between(min, max = -1)
        min = [0, min].max
        max = min > max ? 1.0 / 0.0 : max
        min..max
      end
    end
  end
end
