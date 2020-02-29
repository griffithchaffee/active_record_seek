require "test_helper"

class ActiveRecordSeekTest::SeekTest < ActiveRecordSeekTest::QueryTest

  def test_seek_unknown_association
    assert_raises(ArgumentError) do
      MemberGroup.seek("unknown.id.eq" => 1).to_sql
    end
  end

end
