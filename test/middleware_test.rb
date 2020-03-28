require "test_helper"

class ActiveRecordSeekTest::MiddlewareTest < ActiveRecordSeekTest::QueryTest

  def setup
    ActiveRecordSeek::Middleware.middleware.clear
  end

  def teardown
    ActiveRecordSeek::Middleware.middleware.clear
  end

  def test_middleware_active_record_relation_to_sql
    # middleware
    ActiveRecordSeek::Middleware.new(name: "active_record_relation_to_sql") do |component|
      # check for subquery operator
      return if !component.operator.in?(%w[ in not_in ])
      # check for subquery value
      return if !component.value.is_a?(ActiveRecord::Relation)
      subquery = component.value
      # force primary key selection if no selection made
      first_select = subquery.arel.projections.first
      if first_select && first_select.name == "*"
        subquery = subquery.select(subquery.primary_key)
      end
      # Arel.sql allows for safe sql
      component.value = Arel.sql(subquery.to_sql)
    end
    # no select uses primary key
    query = Group.seek("id.in" => Group.all)
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."id" IN (SELECT "groups"."id" FROM "groups"))},
      query.to_sql
    )
    # with column select
    query = Group.seek("name.in" => Group.select(:name))
    assert_equal_sql(
      %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" IN (SELECT "groups"."name" FROM "groups"))},
      query.to_sql
    )
  end

  def test_middleware_exception
    # manually raised exception
    ActiveRecordSeek::Middleware.new(name: "middleware_exception") do |component|
      raise(RuntimeError, "error message")
    end
    assert_raises(RuntimeError) do
      Group.seek("id.eq" => 0)
    end
  end

end

