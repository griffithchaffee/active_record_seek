require "test_helper"

class ActiveRecordSeekTest::SeekTest < ActiveRecordSeekTest::QueryTest
=begin
  def test_seek_eq
    group1 = FactoryBot.create(:group, name: "group1")
    query  = Group.seek("id.eq" => group1.id)
    assert_equal_sql(
      %Q{
        SELECT "groups".* FROM "groups" WHERE (
          "groups"."id" = #{group1.id}
        )
      },
      query.to_sql
    )
    assert_equal_groups([group1], query)
  end

  def test_seek_belongs_to_association_eq
    group1  = FactoryBot.create(:group, name: "group1")
    member1 = FactoryBot.create(:member, name: "member1", groups: [group1])
    query   = Group.seek("member_groups.member_id.eq" => member1.id)
    assert_equal_sql(
      %Q{
        SELECT "groups".* FROM "groups" WHERE (
          "groups"."id" IN (
            SELECT "member_groups"."group_id" FROM "member_groups" WHERE "member_groups"."member_id" = #{member1.id}
          )
        )
      },
      query.to_sql
    )
    assert_equal_groups([group1], query)
  end

  def test_seek_through_association_eq
    group1  = FactoryBot.create(:group, name: "group1")
    member1 = FactoryBot.create(:member, name: "member1", groups: [group1])
    query   = Group.seek("members.id.eq" => member1.id)
    assert_equal_sql(
      %Q{
        SELECT "groups".* FROM "groups" WHERE (
          "groups"."id" IN (
            SELECT "member_groups"."group_id" FROM "member_groups" WHERE "member_groups"."member_id" IN (
              SELECT "members"."id" FROM "members" WHERE "members"."id" = #{member1.id}
            )
          )
        )
      },
      query.to_sql
    )
    assert_equal_groups([group1], query)
  end

  def test_seek_unscoped_namespace
    group1  = FactoryBot.create(:group, name: "group1")
    group2  = FactoryBot.create(:group, name: "group2")
    group3  = FactoryBot.create(:group, name: "group3")
    member1 = FactoryBot.create(:member, name: "member1", groups: [group1])
    member2 = FactoryBot.create(:member, name: "member2", groups: [group2])
    member3 = FactoryBot.create(:member, name: "member3", groups: [group3])
    query1  = Group.seek(
      "unscoped.members.id.eq"   => member1.id,
      "unscoped.members.name.eq" => member2.name,
    )
    query2  = Group.seek(
      "a.members.id.eq"   => member1.id,
      "b.members.name.eq" => member2.name,
    )
    $debug = true
    [query1, query2].each_with_index do |query, i|
      query_variable = "query#{i + 1}"
      puts query.to_sql
      assert_equal_sql(
        %Q{
          SELECT "groups".* FROM "groups" WHERE (
            "groups"."id" IN (
              SELECT "member_groups"."group_id" FROM "member_groups" WHERE "member_groups"."member_id" IN (
                SELECT "members"."id" FROM "members" WHERE (
                  "members"."id" = #{member1.id} OR "members"."name" = '#{member2.name}'
                )
              )
            )
          )
        },
        query.to_sql,
        query_variable,
      )
      assert_equal_groups([group1, group2], query, query_variable)
    end
  ensure
    $debug = false
  end
=end
end

