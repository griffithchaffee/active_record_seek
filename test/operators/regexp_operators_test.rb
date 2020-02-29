require "test_helper"

class ActiveRecordSeekTest::SeekTest < ActiveRecordSeekTest::QueryTest

  # case sensitive
  def test_operator_regexp
    if AdapterDatabase.instance.adapter_name.in?(%w[ SQLite Mysql2 ])
      assert_raises(NotImplementedError) do
        Group.seek("name.regexp" => "test1").to_sql
      end
    else
      assert_equal_sql(
        %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" ~ 'test1')},
        Group.seek("name.regexp" => "test1").to_sql,
        "regexp"
      )
    end
  end

  def test_operator_regexp_all
    if AdapterDatabase.instance.adapter_name.in?(%w[ SQLite Mysql2 ])
      assert_raises(NotImplementedError) do
        Group.seek("name.regexp_all" => ["test1", "test2"]).to_sql
      end
    else
      assert_equal_sql(
        %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" ~ 'test1' AND "groups"."name" ~ 'test2')},
        Group.seek("name.regexp_all" => ["test1", "test2"]).to_sql,
        "regexp_all"
      )
    end
  end

  def test_operator_regexp_any
    if AdapterDatabase.instance.adapter_name.in?(%w[ SQLite Mysql2 ])
      assert_raises(NotImplementedError) do
        Group.seek("name.regexp_any" => ["test1", "test2"]).to_sql
      end
    else
      assert_equal_sql(
        %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."name" ~ 'test1' OR "groups"."name" ~ 'test2'))},
        Group.seek("name.regexp_any" => ["test1", "test2"]).to_sql,
        "regexp_all"
      )
    end
  end

  def test_operator_not_regexp
    if AdapterDatabase.instance.adapter_name.in?(%w[ SQLite Mysql2 ])
      assert_raises(NotImplementedError) do
        Group.seek("name.not_regexp" => "test1").to_sql
      end
    else
      assert_equal_sql(
        %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" !~ 'test1')},
        Group.seek("name.not_regexp" => "test1").to_sql,
        "not_regexp"
      )
    end
  end

  def test_operator_not_regexp_all
    if AdapterDatabase.instance.adapter_name.in?(%w[ SQLite Mysql2 ])
      assert_raises(NotImplementedError) do
        Group.seek("name.not_regexp_all" => ["test1", "test2"]).to_sql
      end
    else
      assert_equal_sql(
        %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" !~ 'test1' AND "groups"."name" !~ 'test2')},
        Group.seek("name.not_regexp_all" => ["test1", "test2"]).to_sql,
        "not_regexp_all"
      )
    end
  end

  def test_operator_not_regexp_any
    if AdapterDatabase.instance.adapter_name.in?(%w[ SQLite Mysql2 ])
      assert_raises(NotImplementedError) do
        Group.seek("name.not_regexp_any" => ["test1", "test2"]).to_sql
      end
    else
      assert_equal_sql(
        %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."name" !~ 'test1' OR "groups"."name" !~ 'test2'))},
        Group.seek("name.not_regexp_any" => ["test1", "test2"]).to_sql,
        "not_regexp_all"
      )
    end
  end

  # case insensitive
  def test_operator_ci_regexp
    if AdapterDatabase.instance.adapter_name.in?(%w[ SQLite Mysql2 ])
      assert_raises(NotImplementedError) do
        Group.seek("name.ci_regexp" => "test1").to_sql
      end
    else
      assert_equal_sql(
        %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" ~* 'test1')},
        Group.seek("name.ci_regexp" => "test1").to_sql,
        "ci_regexp"
      )
    end
  end

  def test_operator_ci_regexp_all
    if AdapterDatabase.instance.adapter_name.in?(%w[ SQLite Mysql2 ])
      assert_raises(NotImplementedError) do
        Group.seek("name.ci_regexp_all" => ["test1", "test2"]).to_sql
      end
    else
      assert_equal_sql(
        %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" ~* 'test1' AND "groups"."name" ~* 'test2')},
        Group.seek("name.ci_regexp_all" => ["test1", "test2"]).to_sql,
        "ci_regexp_all"
      )
    end
  end

  def test_operator_ci_regexp_any
    if AdapterDatabase.instance.adapter_name.in?(%w[ SQLite Mysql2 ])
      assert_raises(NotImplementedError) do
        Group.seek("name.ci_regexp_any" => ["test1", "test2"]).to_sql
      end
    else
      assert_equal_sql(
        %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."name" ~* 'test1' OR "groups"."name" ~* 'test2'))},
        Group.seek("name.ci_regexp_any" => ["test1", "test2"]).to_sql,
        "ci_regexp_all"
      )
    end
  end

  def test_operator_not_ci_regexp
    if AdapterDatabase.instance.adapter_name.in?(%w[ SQLite Mysql2 ])
      assert_raises(NotImplementedError) do
        Group.seek("name.not_ci_regexp" => "test1").to_sql
      end
    else
      assert_equal_sql(
        %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" !~* 'test1')},
        Group.seek("name.not_ci_regexp" => "test1").to_sql,
        "not_ci_regexp"
      )
    end
  end

  def test_operator_not_ci_regexp_all
    if AdapterDatabase.instance.adapter_name.in?(%w[ SQLite Mysql2 ])
      assert_raises(NotImplementedError) do
        Group.seek("name.not_ci_regexp_all" => ["test1", "test2"]).to_sql
      end
    else
      assert_equal_sql(
        %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" !~* 'test1' AND "groups"."name" !~* 'test2')},
        Group.seek("name.not_ci_regexp_all" => ["test1", "test2"]).to_sql,
        "not_ci_regexp_all"
      )
    end
  end

  def test_operator_not_ci_regexp_any
    if AdapterDatabase.instance.adapter_name.in?(%w[ SQLite Mysql2 ])
      assert_raises(NotImplementedError) do
        Group.seek("name.not_ci_regexp_any" => ["test1", "test2"]).to_sql
      end
    else
      assert_equal_sql(
        %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."name" !~* 'test1' OR "groups"."name" !~* 'test2'))},
        Group.seek("name.not_ci_regexp_any" => ["test1", "test2"]).to_sql,
        "not_ci_regexp_all"
      )
    end
  end

end
