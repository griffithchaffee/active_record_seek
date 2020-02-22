require "test_helper"

class ActiveRecordSeekTest::SeekTest < ActiveRecordSeekTest::QueryTest

  # case sensitive tests
  def test_operator_in
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" IN ('test1', 'test2'))},
      Group.seek("name.in" => %w[ test1 test2 ]).to_sql,
      "in"
    )
  end

  def test_operator_in_all
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."name" IN ('test1', 'test2') AND "groups"."name" IN ('test3', 'test4')))},
      Group.seek("name.in_all" => [%w[ test1 test2 ], %w[ test3 test4 ]]).to_sql,
      "in_all"
    )
  end

  def test_operator_in_any
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."name" IN ('test1', 'test2') OR "groups"."name" IN ('test3', 'test4')))},
      Group.seek("name.in_any" => [%w[ test1 test2 ], %w[ test3 test4 ]]).to_sql,
      "in_any"
    )
  end

  def test_operator_not_in
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" NOT IN ('test1', 'test2'))},
      Group.seek("name.not_in" => %w[ test1 test2 ]).to_sql,
      "not_in"
    )
  end

  def test_operator_not_in_all
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."name" NOT IN ('test1', 'test2') AND "groups"."name" NOT IN ('test3', 'test4')))},
      Group.seek("name.not_in_all" => [%w[ test1 test2 ], %w[ test3 test4 ]]).to_sql,
      "not_in_all"
    )
  end

  def test_operator_not_in_any
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."name" NOT IN ('test1', 'test2') OR "groups"."name" NOT IN ('test3', 'test4')))},
      Group.seek("name.not_in_any" => [%w[ test1 test2 ], %w[ test3 test4 ]]).to_sql,
      "not_in_any"
    )
  end

  # case insensitive tests
  def test_operator_ci_in
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (LOWER("groups"."name") IN (LOWER('test1'), LOWER('test2')))},
      Group.seek("name.ci_in" => %w[ test1 test2 ]).to_sql,
      "ci_in"
    )
  end

  def test_operator_ci_in_all
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ((LOWER("groups"."name") IN (LOWER('test1'), LOWER('test2')) AND LOWER("groups"."name") IN (LOWER('test3'), LOWER('test4'))))},
      Group.seek("name.ci_in_all" => [%w[ test1 test2 ], %w[ test3 test4 ]]).to_sql,
      "ci_in_all"
    )
  end

  def test_operator_ci_in_any
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ((LOWER("groups"."name") IN (LOWER('test1'), LOWER('test2')) OR LOWER("groups"."name") IN (LOWER('test3'), LOWER('test4'))))},
      Group.seek("name.ci_in_any" => [%w[ test1 test2 ], %w[ test3 test4 ]]).to_sql,
      "ci_in_any"
    )
  end

  def test_operator_not_ci_in
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (LOWER("groups"."name") NOT IN (LOWER('test1'), LOWER('test2')))},
      Group.seek("name.not_ci_in" => %w[ test1 test2 ]).to_sql,
      "not_ci_in"
    )
  end

  def test_operator_not_ci_in_all
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ((LOWER("groups"."name") NOT IN (LOWER('test1'), LOWER('test2')) AND LOWER("groups"."name") NOT IN (LOWER('test3'), LOWER('test4'))))},
      Group.seek("name.not_ci_in_all" => [%w[ test1 test2 ], %w[ test3 test4 ]]).to_sql,
      "not_ci_in_all"
    )
  end

  def test_operator_not_ci_in_any
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ((LOWER("groups"."name") NOT IN (LOWER('test1'), LOWER('test2')) OR LOWER("groups"."name") NOT IN (LOWER('test3'), LOWER('test4'))))},
      Group.seek("name.not_ci_in_any" => [%w[ test1 test2 ], %w[ test3 test4 ]]).to_sql,
      "not_ci_in_any"
    )
  end

end
