module Duplex
  module Selector
    class Unsafe
      def initialize(file_refs)
        @matching = file_refs
        @not_matching = []
      end

      # Filters

      def with_path(pattern, &block)
        select {|ref| ref.path.index(pattern)}
        yield_both(&block)
        self
      end

      def with_name(pattern, &block)
        select {|ref| ref.name.index(pattern)}
        yield_both(&block)
        self
      end

      def with_ext(ext, &block)
        ext = "." + ext unless ext.start_with?(".")
        select {|ref| ref.ext == ext}
        yield_both(&block)
        self
      end

      def with_sha(string, &block)
        select {|ref| ref.sha == string}
        yield_both(&block)
        self
      end

      def with_size(min, max = nil, &block)
        range = range_between(min, max || min)
        select {|ref| range === ref.size}
        yield_both(&block)
        self
      end

      def with_uniq_name(&block)
        select_uniq(&:name)
        yield_both(&block)
        return self
      end

      def with_uniq_location(&block)
        select_uniq(&:location)
        yield_both(&block)
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

      def select(&block)
        matches = @matching.select(&block)
        @not_matching.concat(@matching - matches)
        @matching = matches
      end

      def select_uniq(&fn)
        if @matching.uniq(&fn).count > 1
          @not_matching.concat(@matching)
          @matching = []
        end
      end

      def yield_both(&block)
        yield @matching, @not_matching if block_given?
      end

      def range_between(min, max = -1)
        min = [0, min].max
        max = min > max ? 1.0 / 0.0 : max
        min..max
      end
    end
  end
end
