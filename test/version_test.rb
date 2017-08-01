require "test_helper"

class ActiveRecordSeek::VersionTest < Minitest::Test
  def test_version_number
    refute_nil ::ActiveRecordSeek::VERSION
  end
end
