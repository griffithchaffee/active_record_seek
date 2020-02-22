require "test_helper"

class ActiveRecordSeekTest::SeekTest < ActiveRecordSeekTest::QueryTest

  # case sensitive tests
  def test_operator_eq
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" = 'test1')},
      Group.seek("name.eq" => "test1").to_sql,
      "eq"
    )
  end

  def test_operator_eq_all
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."name" = 'test1' AND "groups"."name" = 'test2'))},
      Group.seek("name.eq_all" => %w[ test1 test2 ]).to_sql,
      "eq_all"
    )
  end

  def test_operator_eq_any
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."name" = 'test1' OR "groups"."name" = 'test2'))},
      Group.seek("name.eq_any" => %w[ test1 test2 ]).to_sql,
      "eq_any"
    )
  end

  def test_operator_not_eq
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" != 'test1')},
      Group.seek("name.not_eq" => "test1").to_sql,
      "not_eq"
    )
  end

  def test_operator_not_eq_all
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."name" != 'test1' AND "groups"."name" != 'test2'))},
      Group.seek("name.not_eq_all" => %w[ test1 test2 ]).to_sql,
      "not_eq_all"
    )
  end

  def test_operator_not_eq_any
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."name" != 'test1' OR "groups"."name" != 'test2'))},
      Group.seek("name.not_eq_any" => %w[ test1 test2 ]).to_sql,
      "not_eq_any"
    )
  end

  # case insensitive tests
  def test_operator_ci_eq
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (LOWER("groups"."name") = LOWER('test1'))},
      Group.seek("name.ci_eq" => "test1").to_sql,
      "ci_eq"
    )
  end

  def test_operator_ci_eq_all
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ((LOWER("groups"."name") = LOWER('test1') AND LOWER("groups"."name") = LOWER('test2')))},
      Group.seek("name.ci_eq_all" => %w[ test1 test2 ]).to_sql,
      "ci_eq_all"
    )
  end

  def test_operator_ci_eq_any
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ((LOWER("groups"."name") = LOWER('test1') OR LOWER("groups"."name") = LOWER('test2')))},
      Group.seek("name.ci_eq_any" => %w[ test1 test2 ]).to_sql,
      "ci_eq_any"
    )
  end

  def test_operator_not_ci_eq
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (LOWER("groups"."name") != LOWER('test1'))},
      Group.seek("name.not_ci_eq" => "test1").to_sql,
      "not_ci_eq"
    )
  end

  def test_operator_not_ci_eq_all
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ((LOWER("groups"."name") != LOWER('test1') AND LOWER("groups"."name") != LOWER('test2')))},
      Group.seek("name.not_ci_eq_all" => %w[ test1 test2 ]).to_sql,
      "not_ci_eq_all"
    )
  end

  def test_operator_not_ci_eq_any
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ((LOWER("groups"."name") != LOWER('test1') OR LOWER("groups"."name") != LOWER('test2')))},
      Group.seek("name.not_ci_eq_any" => %w[ test1 test2 ]).to_sql,
      "not_ci_eq_any"
    )
  end

end

