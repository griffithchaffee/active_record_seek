require "test_helper"

class ActiveRecordSeekTest::SeekTest < ActiveRecordSeekTest::QueryTest

  def test_operator_like
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" LIKE 'test')},
      Group.seek("name.like" => "test").to_sql
    )
  end

  def test_operator_not_like
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" NOT LIKE 'test')},
      Group.seek("name.not_like" => "test").to_sql
    )
  end

  def test_operator_ilike
    if false
      assert_equal_sql(
        %Q{SELECT "groups".* FROM "groups" WHERE (LOWER("groups"."name") LIKE LOWER('test'))},
        Group.seek("name.ilike" => "test").to_sql
      )
    else
      assert_equal_sql(
        %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" LIKE 'test')},
        Group.seek("name.like" => "test").to_sql
      )
    end
  end

  def test_operator_not_ilike
    if false
      assert_equal_sql(
        %Q{SELECT "groups".* FROM "groups" WHERE (LOWER("groups"."name") NOT LIKE LOWER('test'))},
        Group.seek("name.not_ilike" => "test").to_sql
      )
    else
      assert_equal_sql(
        %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" NOT LIKE 'test')},
        Group.seek("name.not_like" => "test").to_sql
      )
    end
  end

end

