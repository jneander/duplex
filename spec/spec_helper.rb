require "coveralls"
Coveralls.wear!

require "fileutils"

require "duplex"

TMP_PATH = File.join(__dir__, ".tmp/")

module FileHelpers
  def tmp_path(subpath = "")
    File.join(TMP_PATH, subpath)
  end
end

module DataHelpers
  def next_id
    @data_id ||= 0; @data_id += 1
  end

  def example_path(id, attr)
    location = attr[:location] || "/example/path"
    name = attr[:name] || "file-#{id}"
    ext = attr[:ext] || ".jpg"
    File.join(location, name + ext)
  end

  def create_file_ref(attr = {})
    id = next_id.to_s
    Duplex::FileRef.new({
      path: example_path(id, attr),
      sha: "da39a3ee5e6b4b0d3255bfef95601890afd80709".slice(0, 40 - id.size) + id,
      size: 1024 + id.to_i
    }.merge(attr))
  end
end

module SpecHelpers
  class Spy
    def initialize
      @called = false
      @yielded = []
    end

    def block
      Proc.new {|arg|
        @yielded << arg
        @called = true
      }
    end

    def called?
      !!@called
    end

    def yielded
      @yielded
    end
  end

  def create_spy
    Spy.new
  end
end

RSpec.configure do |config|
  config.include FileHelpers
  config.include DataHelpers
  config.include SpecHelpers
  config.alias_it_should_behave_like_to :it_behaves_like, "behaves like"

  config.after(:each) do
    FileUtils.rm_rf(TMP_PATH)
  end
end
