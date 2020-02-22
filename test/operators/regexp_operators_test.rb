require "test_helper"

class ActiveRecordSeekTest::SeekTest < ActiveRecordSeekTest::QueryTest

  def test_operator_regexp
    if AdapterDatabase.instance.adapter_name.in?(%w[ SQLite Mysql2 ])
      assert_raises(NotImplementedError) do
        Group.seek("name.not_ci_regexp" => "test").to_sql
      end
    else
      assert_equal_sql(
        %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" ~ 'test')},
        Group.seek("name.regexp" => "test").to_sql
      )
    end
  end

  def test_operator_not_regexp
    if AdapterDatabase.instance.adapter_name.in?(%w[ SQLite Mysql2 ])
      assert_raises(NotImplementedError) do
        Group.seek("name.not_ci_regexp" => "test").to_sql
      end
    else
      assert_equal_sql(
        %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" !~ 'test')},
        Group.seek("name.not_regexp" => "test").to_sql
      )
    end
  end

  def test_operator_ci_regexp
    if AdapterDatabase.instance.adapter_name.in?(%w[ SQLite Mysql2 ])
      assert_raises(NotImplementedError) do
        Group.seek("name.not_ci_regexp" => "test").to_sql
      end
    else
      assert_equal_sql(
        %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" ~* 'test')},
        Group.seek("name.ci_regexp" => "test").to_sql
      )
    end
  end

  def test_operator_not_ci_regexp
    if AdapterDatabase.instance.adapter_name.in?(%w[ SQLite Mysql2 ])
      assert_raises(NotImplementedError) do
        Group.seek("name.not_ci_regexp" => "test").to_sql
      end
    else
      assert_equal_sql(
        %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" !~* 'test')},
        Group.seek("name.not_ci_regexp" => "test").to_sql
      )
    end
  end

end
