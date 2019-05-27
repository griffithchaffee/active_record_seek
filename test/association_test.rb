require "test_helper"
require "support/database_models"

class ActiveRecordSeek::AssociationTest < ActiveRecordSeek::ModelTest

  def test_seek_on_association
    member1 = FactoryBot.create(:member)
    group1 = FactoryBot.create(:group, name: "group1")
    group2 = FactoryBot.create(:group, name: "group2")
    # assertions
    assert_sql = -> (expected_where_sql, actual, options = {}) do
      options = options.with_indifferent_access.assert_valid_keys(*%w[ without ])
      actual_sql = actual.to_sql
      expected_sql = %Q[SELECT "members".* FROM "members" WHERE (("members"."id" #{options[:without] ? "NOT IN" : "IN"} ]
      expected_sql << %Q[(SELECT "member_groups"."member_id" FROM "member_groups" WHERE ("member_groups"."group_id" IN ]
      expected_sql << %Q[(SELECT "groups"."id" FROM "groups" #{expected_where_sql})))))]
      puts expected_sql, actual_sql if expected_sql != actual_sql
      assert_equal expected_sql, actual_sql
    end
    member1.groups = [group1, group2]
    # eq
    where_sql = %Q[WHERE ("groups"."name" = '#{group1.name}')]
    assert_sql.call where_sql, Member.seek("groups.name_eq": group1.name)
    # not_eq
    where_sql = %Q[WHERE ("groups"."name" != '#{group1.name}')]
    assert_sql.call where_sql, Member.seek("groups.name_not_eq": group1.name)
    # ieq
    where_sql = %Q[WHERE (LOWER("groups"."name") = LOWER('#{group1.name}'))]
    assert_sql.call where_sql, Member.seek("groups.name_ieq": group1.name)
    # not_ieq
    where_sql = %Q[WHERE (LOWER("groups"."name") != LOWER('#{group1.name}'))]
    assert_sql.call where_sql, Member.seek("groups.name_not_ieq": group1.name)
    # matches
    where_sql = %Q[WHERE ("groups"."name" LIKE '%#{group1.name}%')]
    assert_sql.call where_sql, Member.seek("groups.name_matches": group1.name)
    # does_not_match
    where_sql = %Q[WHERE ("groups"."name" NOT LIKE '%#{group1.name}%')]
    assert_sql.call where_sql, Member.seek("groups.name_does_not_match": group1.name)
    # in
    where_sql = %Q[WHERE ("groups"."name" IN ('#{group1.name}', '#{group2.name}'))]
    assert_sql.call where_sql, Member.seek("groups.name_in": [group1.name, group2.name])
    # not_in
    where_sql = %Q[WHERE ("groups"."name" NOT IN ('#{group1.name}', '#{group2.name}'))]
    assert_sql.call where_sql, Member.seek("groups.name_not_in": [group1.name, group2.name])
    # lt
    where_sql = %Q[WHERE ("groups"."id" < #{group1.id})]
    assert_sql.call where_sql, Member.seek("groups.id_lt": group1.id)
    # lteq
    where_sql = %Q[WHERE ("groups"."id" <= #{group1.id})]
    assert_sql.call where_sql, Member.seek("groups.id_lteq": group1.id)
    # gt
    where_sql = %Q[WHERE ("groups"."id" > #{group1.id})]
    assert_sql.call where_sql, Member.seek("groups.id_gt": group1.id)
    # gteq
    where_sql = %Q[WHERE ("groups"."id" >= #{group1.id})]
    assert_sql.call where_sql, Member.seek("groups.id_gteq": group1.id)
    # multiple scopes
    where_sql = %Q[WHERE ("groups"."id" = #{group1.id}) AND ("groups"."name" = '#{group1.name}')]
    assert_sql.call where_sql, Member.seek("groups.id_eq": group1.id, "groups.name_eq": group1.name)
    # without
    where_sql = %Q[WHERE ("groups"."id" = #{group1.id})]
    assert_sql.call where_sql, Member.seek("without_groups.id_eq": group1.id), without: true
    # without multiple scopes
    where_sql = %Q[WHERE ("groups"."id" = #{group1.id}) AND ("groups"."name" = '#{group1.name}')]
    assert_sql.call where_sql, Member.seek("without_groups.id_eq": group1.id, "without_groups.name_eq": group1.name), without: true
  end

  def test_merge_association_query
    member1 = FactoryBot.create(:member)
    group_category1 = FactoryBot.create(:group_category)
    group1 = FactoryBot.create(:group, name: "group1", category: group_category1)
    group2 = FactoryBot.create(:group, name: "group2", category: group_category1)
    member1.groups = [group1]
    # assertions
    assert_sql = -> (expected_sql, actual) do
      actual_sql = actual.to_sql
      puts expected_sql, actual_sql if expected_sql != actual_sql
      assert_equal expected_sql, actual_sql
    end
    # belongs_to
    expected_sql = ""
    expected_sql << %Q[SELECT "groups".* FROM "groups" WHERE (("groups"."category_id" IN ]
    expected_sql << %Q[(SELECT "group_categories"."id" FROM "group_categories" WHERE "group_categories"."id" = #{group_category1.id})))]
    assert_sql.call expected_sql, Group.merge_association_query(:category, GroupCategory.where(id: group_category1))
    # has_one
    expected_sql = ""
    expected_sql << %Q[SELECT "member_groups".* FROM "member_groups" WHERE (("member_groups"."group_id" IN ]
    expected_sql << %Q[(SELECT "groups"."id" FROM "groups" WHERE ("groups"."category_id" IN ]
    expected_sql << %Q[(SELECT "group_categories"."id" FROM "group_categories" WHERE "group_categories"."id" = #{group_category1.id})))))]
    assert_sql.call expected_sql, MemberGroup.merge_association_query(:category, GroupCategory.where(id: group_category1))
    # has_many
    expected_sql = ""
    expected_sql << %Q[SELECT "members".* FROM "members" WHERE (("members"."id" IN ]
    expected_sql << %Q[(SELECT "member_groups"."member_id" FROM "member_groups" WHERE "member_groups"."group_id" = #{group1.id})))]
    assert_sql.call expected_sql, Member.merge_association_query(:member_groups, MemberGroup.where(group_id: group1))
    # has_many through
    expected_sql = ""
    expected_sql << %Q[SELECT "members".* FROM "members" WHERE (("members"."id" IN ]
    expected_sql << %Q[(SELECT "member_groups"."member_id" FROM "member_groups" WHERE ("member_groups"."group_id" IN ]
    expected_sql << %Q[(SELECT "groups"."id" FROM "groups" WHERE "groups"."id" = #{group1.id})))))]
    assert_sql.call expected_sql, Member.all.merge_association_query(:groups, Group.where(id: group1))
    # has_many through has_many
    expected_sql = ""
    expected_sql << %Q[SELECT "members".* FROM "members" WHERE (("members"."id" IN ]
    expected_sql << %Q[(SELECT "member_groups"."member_id" FROM "member_groups" WHERE ("member_groups"."group_id" IN ]
    expected_sql << %Q[(SELECT "groups"."id" FROM "groups" WHERE ("groups"."category_id" IN ]
    expected_sql << %Q[(SELECT "group_categories"."id" FROM "group_categories" WHERE "group_categories"."id" = #{group_category1.id})))))))]
    assert_sql.call expected_sql, Member.all.merge_association_query(:group_categories, GroupCategory.where(id: group_category1.id))
    # throughception
    GroupProperty.send(:has_many, :test_members, through: :group, source: :members)
    expected_sql = ""
    expected_sql << %Q[SELECT "group_properties".* FROM "group_properties" WHERE (("group_properties"."group_id" IN ]
    expected_sql << %Q[(SELECT "groups"."id" FROM "groups" WHERE ("groups"."id" IN ]
    expected_sql << %Q[(SELECT "member_groups"."group_id" FROM "member_groups" WHERE ("member_groups"."member_id" IN ]
    expected_sql << %Q[(SELECT "members"."id" FROM "members" WHERE "members"."id" = #{member1.id})))))))]
    assert_sql.call expected_sql, GroupProperty.merge_association_query(:test_members, Member.where(id: member1))
    # has_many not_in
    expected_sql = ""
    expected_sql << %Q[SELECT "members".* FROM "members" WHERE (("members"."id" NOT IN ]
    expected_sql << %Q[(SELECT "member_groups"."member_id" FROM "member_groups" WHERE "member_groups"."group_id" = #{group1.id})))]
    assert_sql.call expected_sql, Member.merge_association_query(:member_groups, MemberGroup.where(group_id: group1), operator: :not_in)
    # multiple merge scopes
    expected_sql = ""
    expected_sql << %Q[SELECT "members".* FROM "members" WHERE (("members"."id" IN ]
    expected_sql << %Q[(SELECT "member_groups"."member_id" FROM "member_groups" WHERE ("member_groups"."group_id" IN ]
    expected_sql << %Q[(SELECT "groups"."id" FROM "groups" WHERE ("groups"."id" = #{group1.id}) AND ("groups"."name" = '#{group1.name}')))))) ]
    expected_sql << %Q[AND (("members"."id" IN ]
    expected_sql << %Q[(SELECT "member_groups"."member_id" FROM "member_groups" WHERE ("member_groups"."group_id" IN ]
    expected_sql << %Q[(SELECT "groups"."id" FROM "groups" WHERE ("groups"."id" = #{group2.id})))))) ]
    expected_sql << %Q[AND (("members"."id" IN ]
    expected_sql << %Q[(SELECT "member_groups"."member_id" FROM "member_groups" WHERE ("member_groups"."group_id" IN ]
    expected_sql << %Q[(SELECT "groups"."id" FROM "groups" WHERE ("groups"."name" = '#{group2.name}'))))))]
    assert_sql.call(
      expected_sql,
      Member.seek(
        "groups.id_eq": group1.id,
        "groups.name_eq": group1.name,
        "unscoped_groups.id_eq": group2.id,
        "unscoped_groups.name_eq": group2.name
      )
    )
    assert_sql.call(
      expected_sql,
      Member.all
        .merge_association_query(:groups, Group.where_id(eq: group1.id).where_name(eq: group1.name))
        .merge_association_query(:groups, Group.where_id(eq: group2.id))
        .merge_association_query(:groups, Group.where_name(eq: group2.name))
    )
  end
=begin
  def testing "find_in_ordered_batches" do
    event1 = FactoryBot.create(:event, name: "event1", description: nil)
    event2 = FactoryBot.create(:event, name: "event2", description: nil)
    event3 = FactoryBot.create(:event, name: "event3", description: nil)
    # default ordering is by id
    assert_batches = -> (expected_batches, query, batching_options = {}) do
      actual_batches = []
      actual_records = []
      query.find_in_ordered_batches(batching_options) { |batch| actual_batches << batch }
      query.find_each_in_order(batching_options) { |record| actual_records << record }
      assert_equal(expected_batches.map { |batch| batch.map(&:name) }, actual_batches.map { |batch| batch.map(&:name) })
      assert_equal(expected_batches.flatten.map(&:name), actual_records.map(&:name))
    end
    # unordered default to id DESC
    assert_batches.call([[event3, event2, event1]], Event.all)
    assert_batches.call([[event3, event2, event1]], Event.order_description)
    assert_batches.call([[event1, event2, event3]], Event.order_name)
    assert_batches.call([[event1, event2, event3]], Event.order_id)
    # batch_size
    assert_batches.call([[event3], [event2], [event1]], Event.all, batch_size: 1)
    assert_raises(ArgumentError) { assert_batches.call([[event3, event2, event1]], Event.all, batch_size: 0) }
    # offset
    assert_batches.call([[event2], [event1]], Event.all, batch_size: 1, offset: 1)
    assert_batches.call([[event1]], Event.all, batch_size: 1, offset: 2)
    assert_batches.call([], Event.all, batch_size: 1, offset: 3)
    assert_raises(ArgumentError) { assert_batches.call([], Event.all, batch_size: 1, offset: -1) }
  end
=end
end
