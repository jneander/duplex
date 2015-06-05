module Duplex
  class Identifier
    def initialize(file_refs)
      @file_refs = file_refs
    end

    def duplicates
      identify unless @duplicates
      @duplicates
    end

    def unique
      identify unless @unique
      @unique
    end

    def incomplete
      identify unless @incomplete
      @incomplete
    end

    private

    def identify
      unique = []
      incomplete = []

      with_sha = @file_refs.reject {|file_ref| !file_ref.sha}
      by_sha = with_sha.group_by(&:sha)
      by_size = (@file_refs - with_sha).group_by(&:size)
      join = @file_refs.select {|file_ref| file_ref.size && file_ref.sha}.group_by(&:size)

      by_size.each do |size, file_refs|
        if join.include?(size)
          sha = join[size].first.sha
          by_sha.delete(sha)
          incomplete.concat(file_refs)
        elsif file_refs.count == 1
          unique.concat(file_refs)
        else
          incomplete.concat(file_refs)
        end
      end

      by_sha.each do |sha, file_refs|
        unless file_refs.count > 1
          unique.concat(by_sha.delete(sha))
        end
      end

      if @file_refs.all? {|file_ref| file_ref.size || file_ref.sha}
        @unique = unique
        @duplicates = by_sha.values
        @incomplete = incomplete
      else
        @unique = []
        @duplicates = []
        @incomplete = (incomplete + @file_refs.reject {|file_ref| file_ref.size && file_ref.sha}).uniq
      end
    end
  end
end
