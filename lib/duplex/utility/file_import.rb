module Duplex
  class FileImport
    def initialize(config)
      @datastore = config[:datastore]
      @filestore = config[:filestore]
    end

    def from_path(path)
      file_refs = @filestore.nested_files(path).map {|path| FileRef.new(path: path)}
      @datastore.add_file_refs(file_refs)
      @datastore.to_a.each do |file_ref| @filestore.assign_size(file_ref) end
      @datastore.to_a.group_by(&:size).each do |size, file_refs|
        next unless file_refs.count > 1
        file_refs.each do |file_ref|
          @filestore.assign_sha(file_ref)
        end
      end
    end
  end
end
