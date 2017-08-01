require "test_helper"
require "support/database_models"

class ActiveRecordSeek::OperatorTest < ActiveRecordSeek::ModelTest
  def test_find_operator
    # assertion helper
    assert_find_operator = -> (column_and_operator, expected_match_params) do
      matched_operator = ActiveRecordSeek::Operator.find_by_match!(column_and_operator)
      assert_equal({
        column_and_operator: column_and_operator,
        column: column_and_operator.remove(matched_operator.matcher),
        operator: matched_operator.operator,
      }, expected_match_params.merge(column_and_operator: column_and_operator))
    end
    # suffix operators
    %i[
      gt lt gteq lteq
      eq ieq in
      not_eq not_ieq not_in
      matches does_not_match
    ].each do |suffix_operator|
      assert_find_operator.call("name_#{suffix_operator}", column: "name", operator: suffix_operator)
    end
    # bang method raises ArgumentError
    invalid_column_and_operator = "invalid_column_and_operator"
    assert_raises(ArgumentError) do
      ActiveRecordSeek::Operator.find_by_match!(invalid_column_and_operator)
    end
    # optional finder
    matched_operator = ActiveRecordSeek::Operator.find_by_match(invalid_column_and_operator)
    assert_nil(matched_operator)
  end

  def test_normalize_value
    group = FactoryGirl.create(:group)
    FactoryGirl.create_list(:group, 4)
    groups = Group.all
    # assertion helper
    assert_normalized_value = -> (operator:, initial_value:, expected_value:, options: {}) do
      matched_operator = ActiveRecordSeek::Operator.find_by_match!(operator)
      normalized_value = matched_operator.normalize_value(initial_value, options)
      normalized_value = normalized_value.to_sql if normalized_value.is_a?(ActiveRecord::Relation)
      if expected_value.nil?
        assert_nil(normalized_value, "#{operator} should modify #{initial_value.inspect} to nil")
      else
        assert_equal(expected_value, normalized_value, "#{operator} should modify #{initial_value.inspect} to #{expected_value.inspect}")
      end
    end
    # require type casting for record
    assert_raises(ArgumentError) do
      assert_normalized_value.call(operator: :eq, initial_value: group, expected_value: :raises_error)
    end
    # require type casting for records
    assert_raises(ArgumentError) do
      assert_normalized_value.call(operator: :in, initial_value: [:valid, group], expected_value: :raises_error)
    end
    # only in and not_in can have subqueries
    assert_raises(ArgumentError) do
      assert_normalized_value.call(operator: :eq, initial_value: groups, expected_value: :raises_error)
    end
    # in query value normalized to select column
    %w[ in not_in ].each do |operator|
      # relation - default select id
      assert_normalized_value.call(
        operator: operator,
        initial_value: groups,
        expected_value: groups.select(:id).to_sql
      )
      # relation - default with select
      assert_normalized_value.call(
        operator: operator,
        initial_value: groups.select(:name),
        expected_value: groups.select(:name).to_sql
      )
    end
    # in value normalized to array
    %i[ in not_in ].each do |operator|
      assert_normalized_value.call(operator: operator, initial_value: [1, 2],    expected_value: [1, 2])
      assert_normalized_value.call(operator: operator, initial_value: "1,2",     expected_value: ["1", "2"])
      assert_normalized_value.call(operator: operator, initial_value: " 1 , 2 ", expected_value: [" 1 ", " 2 "])
      assert_normalized_value.call(operator: operator, initial_value: "1,2,,",   expected_value: ["1", "2"])
      assert_normalized_value.call(operator: operator, initial_value: [1, 2, nil, ""], expected_value: [1, 2, nil, ""])
      assert_normalized_value.call(operator: operator, initial_value: [1, 2, nil, ""], expected_value: [1, 2], options: { remove_blank: true })
    end
    # in value normalized to array
    %i[ matches does_not_match ].each do |operator|
      assert_normalized_value.call(operator: operator, initial_value: "match",  expected_value: "%match%")
      assert_normalized_value.call(operator: operator, initial_value: "match%", expected_value: "match%")
      assert_normalized_value.call(operator: operator, initial_value: "^match", expected_value: "match%")
      assert_normalized_value.call(operator: operator, initial_value: "%match", expected_value: "%match")
      assert_normalized_value.call(operator: operator, initial_value: "match$", expected_value: "%match")
      assert_normalized_value.call(operator: operator, initial_value: "   ",    expected_value: nil)
      assert_normalized_value.call(operator: operator, initial_value: nil,      expected_value: nil)
    end
    # default values
    %i[
      eq ieq not_eq not_ieq
      gt lt gteq lteq
    ].each do |operator|
      [
        true, false,
        "", "value"
      ].each do |value|
        assert_normalized_value.call(operator: operator, initial_value: value, expected_value: value)
        assert_normalized_value.call(
          operator: operator,
          initial_value: value,
          expected_value: value.in?([true, false]) ? value : value,
          options: { remove_blank: false }
        )
      end
    end
  end

  def test_to_where_sql
    query = Group.where(name: "blah")
    # basic
    assert_equal(%Q["groups"."name" = 'blah'], query.to_where_sql)
    # select and order ignored
    assert_equal(%Q["groups"."name" = 'blah'], query.select(:id).order(id: :asc).to_where_sql)
    # multiple where attributes
    query = Group.where(name: "blah", id: 1)
    assert_equal(%Q["groups"."name" = 'blah' AND "groups"."id" = 1], query.to_where_sql)
    # multiple wheres
    query = Group.where(name: "blah", id: 1).where(%Q["name" != 'name1'])
    assert_equal(%Q["groups"."name" = 'blah' AND "groups"."id" = 1 AND ("name" != 'name1')], query.to_where_sql)
  end

end
