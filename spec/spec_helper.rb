require "fileutils"

require "duplex"

TMP_PATH = File.join(__dir__, ".tmp/")

module FileHelpers
  def tmp_path(subpath = "")
    File.join(TMP_PATH, subpath)
  end
end

RSpec.configure do |config|
  config.include FileHelpers
  config.alias_it_should_behave_like_to :it_behaves_like, 'behaves like'

  config.after(:each) do
    FileUtils.rm_rf(TMP_PATH)
  end
end
