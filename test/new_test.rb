require("test_helper")
require("support/database_models")

class ActiveRecordSeek::SeekTest < ActiveRecordSeek::ModelTest

  def test_seek
    group1 = FactoryBot.create(:group, name: "group1", description: "desc1")
    group2 = FactoryBot.create(:group, name: "group2", description: "desc2")
    query = Group.seek("id.eq" => group1.id)
    puts query.to_sql
    assert_equal(1, query.count)
  end

end

