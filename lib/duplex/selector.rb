module Duplex
  class Selector
    def initialize(file_refs)
      @file_refs = file_refs
    end

    def with_path(pattern)
      @matching = @file_refs.select {|ref| ref.path.index(pattern)}
      @not_matching = @file_refs - @matching
      self
    end

    def with_name(pattern)
      @matching = @file_refs.select {|ref| ref.name.index(pattern)}
      @not_matching = @file_refs - @matching
      self
    end

    def with_ext(ext)
      ext = "." + ext unless ext.start_with?(".")
      @matching = @file_refs.select {|ref| ref.ext == ext}
      @not_matching = @file_refs - @matching
      self
    end

    def with_sha(string)
      @matching = @file_refs.select {|ref| ref.sha == string}
      @not_matching = @file_refs - @matching
      self
    end

    def with_size(min, max = nil)
      range = range_between(min, max || min)
      @matching = @file_refs.select {|ref| range === ref.size}
      @not_matching = @file_refs - @matching
      self
    end

    def with_label(string)
    end

    def relocate(from, to)
      selection.each do |file_ref|
        next unless file_ref.path.index(from)
        file_ref.destination = file_ref.path.gsub(from, to)
      end
      self
    end

    def drop
    end

    def export_data_list
    end

    def export_plain_text
    end

    def report
    end

    def when_uniq(field)
    end

    def select_any_one
    end

    def prefer
    end

    def reject
    end

    def to_a
      @matching
    end

    def rejected
      @not_matching
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
