require "test_helper"

class ActiveRecordSeekTest::SeekTest < ActiveRecordSeekTest::QueryTest

  def test_seek_association_has_one
    # records
    group1    = FactoryBot.create(:group, name: "group1")
    category1 = FactoryBot.create(:group_category, name: "category1", group: group1)
    # namespaces
    [nil, "unscoped", "namespace"].each do |namespace|
      seek_key   = [namespace, "category.name.eq"].compact.join(".")
      seek_value = category1.name
      seek_hash  = { seek_key => seek_value }
      query = Group.seek(seek_hash)
      assert_equal_sql(
        %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."id" IN (SELECT "group_categories"."group_id" FROM "group_categories" WHERE ("group_categories"."name" = '#{category1.name}')))},
        query.to_sql,
        "seek(#{seek_hash})"
      )
      assert_equal_records([group1], query)
      assert_equal_records([category1], query.map(&:category))
    end
  end

  def test_seek_association_has_one_through
    # records
    group1    = FactoryBot.create(:group, name: "group1")
    member_group1 = FactoryBot.create(:member_group, group: group1)
    category1 = FactoryBot.create(:group_category, name: "category1", group: group1)
    # namespaces
    [nil, "unscoped", "namespace"].each do |namespace|
      seek_key   = [namespace, "category.name.eq"].compact.join(".")
      seek_value = category1.name
      seek_hash  = { seek_key => seek_value }
      query = MemberGroup.seek(seek_hash)
      assert_equal_sql(
        %Q{SELECT "member_groups".* FROM "member_groups" WHERE ("member_groups"."group_id" IN (SELECT "groups"."id" FROM "groups" WHERE "groups"."id" IN (SELECT "group_categories"."group_id" FROM "group_categories" WHERE ("group_categories"."name" = '#{category1.name}'))))},
        query.to_sql,
        "seek(#{seek_hash})"
      )
      assert_equal_records([member_group1], query)
      assert_equal_records([category1], query.map(&:category))
    end
  end

end
