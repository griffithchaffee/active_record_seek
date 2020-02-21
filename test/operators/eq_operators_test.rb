require "test_helper"

class ActiveRecordSeekTest::SeekTest < ActiveRecordSeekTest::QueryTest

  def test_operator_eq
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" = 'test')},
      Group.seek("name.eq" => "test").to_sql
    )
  end

  def test_operator_not_eq
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" != 'test')},
      Group.seek("name.not_eq" => "test").to_sql
    )
  end

  def test_operator_ieq
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (LOWER("groups"."name") = LOWER('test'))},
      Group.seek("name.ieq" => "test").to_sql
    )
  end

  def test_operator_not_ieq
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (LOWER("groups"."name") != LOWER('test'))},
      Group.seek("name.not_ieq" => "test").to_sql
    )
  end

end

