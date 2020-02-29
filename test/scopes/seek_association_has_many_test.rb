require "test_helper"

class ActiveRecordSeekTest::SeekTest < ActiveRecordSeekTest::QueryTest

  def test_seek_association_has_many
    # records
    group1 = FactoryBot.create(:group, name: "group1")
    group2 = FactoryBot.create(:group, name: "group2")
    member1 = FactoryBot.create(:member, name: "member1", groups: [group1])
    FactoryBot.create(:member, name: "member2", groups: [group2])
    member_group1 = member1.member_groups.first
    # variables
    seek_hashes  = []
    namespaces   = %w[ unscoped namespace ]
    # association.name.eq
    seek_hashes.push("member_groups.id.eq" => member_group1.id)
    # namespace.association.name.eq
    namespaces.each do |namespace|
      seek_hashes.push("#{namespace}.member_groups.id.eq" => member_group1.id)
    end
    # assertions
    seek_hashes.each do |seek_hash|
      query = Member.seek(seek_hash)
      assert_equal_sql(
        %Q{SELECT "members".* FROM "members" WHERE ("members"."id" IN (SELECT "member_groups"."member_id" FROM "member_groups" WHERE ("member_groups"."id" = #{member_group1.id})))},
        query.to_sql,
        "seek(#{seek_hash})"
      )
      assert_equal_records([member1], query)
      assert_equal_records([group1], query.first.groups)
    end
  end

  def test_seek_association_has_many_through
    # records
    group1 = FactoryBot.create(:group, name: "group1")
    group2 = FactoryBot.create(:group, name: "group2")
    member1 = FactoryBot.create(:member, name: "member1", groups: [group1])
    FactoryBot.create(:member, name: "member2", groups: [group2])
    # variables
    seek_hashes  = []
    namespaces   = %w[ unscoped namespace ]
    # association.name.eq
    seek_hashes.push("groups.name.eq" => group1.name)
    # namespace.association.name.eq
    namespaces.each do |namespace|
      seek_hashes.push("#{namespace}.groups.name.eq" => group1.name)
    end
    # assertions
    seek_hashes.each do |seek_hash|
      query = Member.seek(seek_hash)
      assert_equal_sql(
        %Q{SELECT "members".* FROM "members" WHERE ("members"."id" IN (SELECT "member_groups"."member_id" FROM "member_groups" WHERE "member_groups"."group_id" IN (SELECT "groups"."id" FROM "groups" WHERE ("groups"."name" = '#{group1.name}'))))},
        query.to_sql,
        "seek(#{seek_hash})"
      )
      assert_equal_records([member1], query)
      assert_equal_records([group1], query.first.groups)
    end
  end

  def test_seek_association_has_many_throughception
    # records
    group1    = FactoryBot.create(:group, name: "group1")
    member1   = FactoryBot.create(:member, name: "member1", groups: [group1])
    category1 = FactoryBot.create(:group_category, name: "category1", group: group1)
    # namespaces
    [nil, "unscoped", "namespace"].each do |namespace|
      seek_key   = [namespace, "members.name.eq"].compact.join(".")
      seek_value = member1.name
      seek_hash  = { seek_key => seek_value }
      query = GroupCategory.seek(seek_hash)
      assert_equal_sql(
        %Q{SELECT "group_categories".* FROM "group_categories" WHERE ("group_categories"."group_id" IN (SELECT "groups"."id" FROM "groups" WHERE "groups"."id" IN (SELECT "member_groups"."group_id" FROM "member_groups" WHERE "member_groups"."member_id" IN (SELECT "members"."id" FROM "members" WHERE ("members"."name" = '#{member1.name}')))))},
        query.to_sql,
        "seek(#{seek_hash})"
      )
      assert_equal_records([category1], query)
      assert_equal_records([member1], query.map(&:members).flatten)
    end
  end

  def test_seek_association_has_many_throughception_source
    # records
    group1    = FactoryBot.create(:group, name: "group1")
    member1   = FactoryBot.create(:member, name: "member1", groups: [group1])
    category1 = FactoryBot.create(:group_category, name: "category1", group: group1)
    # namespaces
    [nil, "unscoped", "namespace"].each do |namespace|
      seek_key   = [namespace, "group_categories.name.eq"].compact.join(".")
      seek_value = category1.name
      seek_hash  = { seek_key => seek_value }
      query = Member.seek(seek_hash)
      assert_equal_sql(
        %Q{SELECT "members".* FROM "members" WHERE ("members"."id" IN (SELECT "member_groups"."member_id" FROM "member_groups" WHERE "member_groups"."group_id" IN (SELECT "groups"."id" FROM "groups" WHERE "groups"."id" IN (SELECT "group_categories"."group_id" FROM "group_categories" WHERE ("group_categories"."name" = '#{category1.name}')))))},
        query.to_sql,
        "seek(#{seek_hash})"
      )
      assert_equal_records([member1], query)
      assert_equal_records([category1], query.map(&:group_categories).flatten)
    end
  end

end
