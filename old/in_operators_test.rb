require "test_helper"

class ActiveRecordSeekTest::SeekTest < ActiveRecordSeekTest::QueryTest

  def test_operator_in
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" IN ('test1', 'test2'))},
      Group.seek("name.in" => ["test1", "test2"]).to_sql
    )
  end

  def test_operator_not_in
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" NOT IN ('test1', 'test2'))},
      Group.seek("name.not_in" => ["test1", "test2"]).to_sql
    )
  end

  def test_operator_ci_in
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (LOWER("groups"."name") IN (LOWER('test1'), LOWER('test2')))},
      Group.seek("name.ci_in" => ["test1", "test2"]).to_sql
    )
  end

  def test_operator_not_ci_in
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (LOWER("groups"."name") NOT IN (LOWER('test1'), LOWER('test2')))},
      Group.seek("name.not_ci_in" => ["test1", "test2"]).to_sql
    )
  end

end

