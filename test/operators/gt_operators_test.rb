require "test_helper"

class ActiveRecordSeekTest::SeekTest < ActiveRecordSeekTest::QueryTest

  def test_operator_gt
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."id" > 1)},
      Group.seek("id.gt" => 1).to_sql,
      "gt"
    )
  end

  def test_operator_gt_all
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."id" > 1 AND "groups"."id" > 2))},
      Group.seek("id.gt_all" => [1, 2]).to_sql,
      "gt_all"
    )
  end

  def test_operator_gt_any
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."id" > 1 OR "groups"."id" > 2))},
      Group.seek("id.gt_any" => [1, 2]).to_sql,
      "gt_any"
    )
  end

  def test_operator_gteq
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."id" >= 1)},
      Group.seek("id.gteq" => 1).to_sql,
      "gteq"
    )
  end

  def test_operator_gteq_all
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."id" >= 1 AND "groups"."id" >= 2))},
      Group.seek("id.gteq_all" => [1, 2]).to_sql,
      "gteq_all"
    )
  end

  def test_operator_gteq_any
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."id" >= 1 OR "groups"."id" >= 2))},
      Group.seek("id.gteq_any" => [1, 2]).to_sql,
      "gteq_any"
    )
  end

end
