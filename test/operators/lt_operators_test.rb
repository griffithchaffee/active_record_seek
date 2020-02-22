require "test_helper"

class ActiveRecordSeekTest::SeekTest < ActiveRecordSeekTest::QueryTest

  def test_operator_lt
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."id" < 1)},
      Group.seek("id.lt" => 1).to_sql,
      "lt"
    )
  end

  def test_operator_lt_all
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."id" < 1 AND "groups"."id" < 2))},
      Group.seek("id.lt_all" => [1, 2]).to_sql,
      "lt_all"
    )
  end

  def test_operator_lt_any
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."id" < 1 OR "groups"."id" < 2))},
      Group.seek("id.lt_any" => [1, 2]).to_sql,
      "lt_any"
    )
  end

  def test_operator_lteq
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."id" <= 1)},
      Group.seek("id.lteq" => 1).to_sql,
      "lteq"
    )
  end

  def test_operator_lteq_all
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."id" <= 1 AND "groups"."id" <= 2))},
      Group.seek("id.lteq_all" => [1, 2]).to_sql,
      "lteq_all"
    )
  end

  def test_operator_lteq_any
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."id" <= 1 OR "groups"."id" <= 2))},
      Group.seek("id.lteq_any" => [1, 2]).to_sql,
      "lteq_any"
    )
  end

end
