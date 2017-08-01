require "test_helper"
require "support/database_models"

class ActiveRecordSeek::PaginateTest < ActiveRecordSeek::ModelTest
  def test_paginate
    # setup
    assert_equal(0, Group.count)
    FactoryGirl.create_list(:group, 5)
    assert_equal(5, Group.count)
    # each_page
    assert_equal([1,2,3], Group.all.paginate(limit: 2).each_page.to_a)
    # assertion helper
    assert_pagination = -> (message, pagination, expected_h) do
      expected_h[:query] = expected_h[:query].to_sql if expected_h[:query]
      result_h = expected_h.map do |k,v|
        [k, k == :query ? pagination.send(k).to_sql : pagination.send(k)]
      end.to_h
      assert_equal(expected_h, result_h, message)
    end
    pagination_defaults = {
      pages:     3,
      raw_count: 5,
      limit:     2,
      limit_min: 1,
      limit_max: 50,
      query: Group.order(id: :desc),
      # require override
      page:               :unset,
      has_next_page?:     :unset,
      has_previous_page?: :unset,
      next_page:          :unset,
      previous_page:      :unset,
      offset:             :unset,
      records:            :unset,
    }
    # default pagination
    assert_pagination.call(
      "default pagination",
      Group.all.paginate,
      pagination_defaults.merge(
        limit: 20,
        pages: 1,
        page: 1,
        has_next_page?: false,
        has_previous_page?: false,
        raw_count: 5,
        next_page: 1,
        previous_page: 1,
        offset: 0,
        records: Group.order(id: :desc).limit(20).to_a,
        size: 5,
      )
    )
    # page 1
    assert_pagination.call(
      "page 1",
      Group.all.paginate(limit: 2),
      pagination_defaults.merge(
        page: 1,
        has_next_page?: true,
        has_previous_page?: false,
        next_page: 2,
        previous_page: 1,
        offset: 0,
        records: Group.order(id: :desc).limit(2).to_a,
        size: 2,
      )
    )
    # page 2
    assert_pagination.call(
      "page 2",
      Group.all.paginate(limit: 2, page: 2),
      pagination_defaults.merge(
        page: 2,
        has_next_page?: true,
        has_previous_page?: true,
        next_page: 3,
        previous_page: 1,
        offset: 2,
        records: Group.order(id: :desc).limit(2).offset(2).to_a,
        size: 2,
      )
    )
    # page 3
    assert_pagination.call(
      "page 3",
      Group.all.paginate(limit: 2, page: 3),
      pagination_defaults.merge(
        page: 3,
        has_next_page?: false,
        has_previous_page?: true,
        next_page: 3,
        previous_page: 2,
        offset: 4,
        records: Group.order(id: :desc).limit(2).offset(4).to_a,
        size: 1,
      )
    )
    # page 4 - uses last page
    assert_pagination.call(
      "invalid max page - uses last page",
      Group.all.paginate(limit: 2, page: 4),
      pagination_defaults.merge(
        page: 3,
        has_next_page?: false,
        has_previous_page?: true,
        next_page: 3,
        previous_page: 2,
        offset: 4,
        records: Group.order(id: :desc).limit(2).offset(4).to_a,
        size: 1,
      )
    )
    # invalid page - uses page 1
    assert_pagination.call(
      "invalid min page - uses first page",
      Group.all.paginate(limit: 2, page: -1),
      pagination_defaults.merge(
        page: 1,
        has_next_page?: true,
        has_previous_page?: false,
        next_page: 2,
        previous_page: 1,
        offset: 0,
        records: Group.order(id: :desc).limit(2).to_a,
        size: 2,
      )
    )
  end

  def test_each_page
    FactoryGirl.create_list(:group, 5)
    assert_equal([1,2,3], Group.all.paginate(limit: 2).each_page.to_a)
  end

  def test_find_each_in_order
    FactoryGirl.create_list(:group, 5)
    # default order by id desc
    batch_ids = -> (query) do
      ids = []
      query.find_each_in_order { |record| ids << record.id }
      ids
    end
    assert_equal(Group.all.order(id: :desc).map(&:id), batch_ids.call(Group.all))
    # different order
    groups = Group.all.order(name: :asc)
    assert_equal(groups.map(&:id), batch_ids.call(groups))
  end
end
