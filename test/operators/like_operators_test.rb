require "test_helper"

class ActiveRecordSeekTest::SeekTest < ActiveRecordSeekTest::QueryTest

  # case sensitive
  def test_operator_like
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" LIKE 'test1')},
      Group.seek("name.like" => "test1").to_sql,
      "like"
    )
  end

  def test_operator_like_all
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."name" LIKE 'test1' AND "groups"."name" LIKE 'test2'))},
      Group.seek("name.like_all" => ["test1", "test2"]).to_sql,
      "like"
    )
  end

  def test_operator_like_any
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."name" LIKE 'test1' OR "groups"."name" LIKE 'test2'))},
      Group.seek("name.like_any" => ["test1", "test2"]).to_sql,
      "like"
    )
  end

  def test_operator_not_like
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" NOT LIKE 'test1')},
      Group.seek("name.not_like" => "test1").to_sql,
      "not_like"
    )
  end

  def test_operator_not_like_all
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."name" NOT LIKE 'test1' AND "groups"."name" NOT LIKE 'test2'))},
      Group.seek("name.not_like_all" => ["test1", "test2"]).to_sql,
      "not_like"
    )
  end

  def test_operator_not_like_any
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."name" NOT LIKE 'test1' OR "groups"."name" NOT LIKE 'test2'))},
      Group.seek("name.not_like_any" => ["test1", "test2"]).to_sql,
      "not_like"
    )
  end

  # case insensitive
  def test_operator_ci_like
    expected_sql =
      if AdapterDatabase.instance.adapter_name.in?(%w[ SQLite Mysql2 ])
        %Q{SELECT "groups".* FROM "groups" WHERE (LOWER("groups"."name") LIKE LOWER('test1'))}
      else
        %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" ILIKE 'test1')}
      end
    assert_equal_sql(
      expected_sql,
      Group.seek("name.ci_like" => "test1").to_sql,
      "ci_like"
    )
  end

  def test_operator_ci_like_all
    expected_sql =
      if AdapterDatabase.instance.adapter_name.in?(%w[ SQLite Mysql2 ])
        %Q{SELECT "groups".* FROM "groups" WHERE ((LOWER("groups"."name") LIKE LOWER('test1') AND LOWER("groups"."name") LIKE LOWER('test2')))}
      else
        %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."name" ILIKE 'test1' AND "groups"."name" ILIKE 'test2'))}
      end
    assert_equal_sql(
      expected_sql,
      Group.seek("name.ci_like_all" => ["test1", "test2"]).to_sql,
      "ci_like"
    )
  end

  def test_operator_ci_like_any
    expected_sql =
      if AdapterDatabase.instance.adapter_name.in?(%w[ SQLite Mysql2 ])
        %Q{SELECT "groups".* FROM "groups" WHERE ((LOWER("groups"."name") LIKE LOWER('test1') OR LOWER("groups"."name") LIKE LOWER('test2')))}
      else
        %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."name" ILIKE 'test1' OR "groups"."name" ILIKE 'test2'))}
      end
    assert_equal_sql(
      expected_sql,
      Group.seek("name.ci_like_any" => ["test1", "test2"]).to_sql,
      "ci_like"
    )
  end

  def test_operator_not_ci_like
    expected_sql =
      if AdapterDatabase.instance.adapter_name.in?(%w[ SQLite Mysql2 ])
        %Q{SELECT "groups".* FROM "groups" WHERE (LOWER("groups"."name") NOT LIKE LOWER('test1'))}
      else
        %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" NOT ILIKE 'test1')}
      end
    assert_equal_sql(
      expected_sql,
      Group.seek("name.not_ci_like" => "test1").to_sql,
      "not_ci_like"
    )
  end

  def test_operator_not_ci_like_all
    expected_sql =
      if AdapterDatabase.instance.adapter_name.in?(%w[ SQLite Mysql2 ])
        %Q{SELECT "groups".* FROM "groups" WHERE ((LOWER("groups"."name") NOT LIKE LOWER('test1') AND LOWER("groups"."name") NOT LIKE LOWER('test2')))}
      else
        %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."name" NOT ILIKE 'test1' AND "groups"."name" NOT ILIKE 'test2'))}
      end
    assert_equal_sql(
      expected_sql,
      Group.seek("name.not_ci_like_all" => ["test1", "test2"]).to_sql,
      "not_ci_like"
    )
  end

  def test_operator_not_ci_like_any
    expected_sql =
      if AdapterDatabase.instance.adapter_name.in?(%w[ SQLite Mysql2 ])
        %Q{SELECT "groups".* FROM "groups" WHERE ((LOWER("groups"."name") NOT LIKE LOWER('test1') OR LOWER("groups"."name") NOT LIKE LOWER('test2')))}
      else
        %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."name" NOT ILIKE 'test1' OR "groups"."name" NOT ILIKE 'test2'))}
      end
    assert_equal_sql(
      expected_sql,
      Group.seek("name.not_ci_like_any" => ["test1", "test2"]).to_sql,
      "not_ci_like"
    )
  end

end
