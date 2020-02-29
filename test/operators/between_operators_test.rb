require "test_helper"

class ActiveRecordSeekTest::SeekTest < ActiveRecordSeekTest::QueryTest

  def test_operator_between
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."id" BETWEEN 1 AND 2)},
      Group.seek("id.between" => 1..2).to_sql,
      "between"
    )
  end

  def test_operator_not_between
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."name" < 'a' OR "groups"."name" > 'b'))},
      Group.seek("name.not_between" => "a".."b").to_sql,
      "not_between"
    )
  end

end

