module Duplex
  class Selector
    def initialize(file_refs)
      @file_refs = file_refs
    end

    # Filters

    def with_path(pattern)
      @matching = @file_refs.select {|ref| ref.path.index(pattern)}
      @not_matching = @file_refs - @matching
      yield @matching, @not_matching if block_given?
      self
    end

    def with_name(pattern)
      @matching = @file_refs.select {|ref| ref.name.index(pattern)}
      @not_matching = @file_refs - @matching
      yield @matching, @not_matching if block_given?
      self
    end

    def with_ext(ext)
      ext = "." + ext unless ext.start_with?(".")
      @matching = @file_refs.select {|ref| ref.ext == ext}
      @not_matching = @file_refs - @matching
      yield @matching, @not_matching if block_given?
      self
    end

    def with_sha(string)
      @matching = @file_refs.select {|ref| ref.sha == string}
      @not_matching = @file_refs - @matching
      yield @matching, @not_matching if block_given?
      self
    end

    def with_size(min, max = nil)
      range = range_between(min, max || min)
      @matching = @file_refs.select {|ref| range === ref.size}
      @not_matching = @file_refs - @matching
      yield @matching, @not_matching if block_given?
      self
    end

    def with_uniq_name
      if @file_refs.uniq {|ref| ref.name}.count == 1
        @matching, @not_matching = @file_refs, []
      else
        @matching, @not_matching = [], @file_refs
      end
      yield @matching, @not_matching if block_given?
      self
    end

    def with_uniq_location
      if @file_refs.uniq {|ref| ref.location}.count == 1
        @matching, @not_matching = @file_refs, []
      else
        @matching, @not_matching = [], @file_refs
      end
      yield @matching, @not_matching if block_given?
      self
    end

    # Stateful Actions (MOVE THESE TO DUPLEX OR ANOTHER CLASS)

    def prefer
    end

    def reject
    end

    def select_any_one
    end

    def relocate(from, to)
      @file_refs.each do |file_ref|
        next unless file_ref.path.index(from)
        file_ref.destination = file_ref.path.gsub(from, to)
      end
      self
    end

    def drop
    end

    def drop!
    end

    # Functional Actions

    def export_data_list
    end

    def export_plain_text
    end

    def report
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
