require "test_helper"

class ActiveRecordSeekTest::SeekTest < ActiveRecordSeekTest::QueryTest

  def test_seek_eq
    group1 = FactoryBot.create(:group, name: "group1", description: "desc1")
    query  = Group.seek("id.eq" => group1.id)
    assert_equal_sql(
      %Q{
        SELECT "groups".* FROM "groups" WHERE ((
          "groups"."id" = #{group1.id}
        ))
      },
      query.to_sql
    )
    assert_equal_groups([group1], query)
  end

  def test_seek_belongs_to_association_eq
    group1  = FactoryBot.create(:group, name: "group1", description: "desc1")
    member1 = FactoryBot.create(:member, name: "member1", groups: [group1])
    query   = Group.seek("member_groups.member_id.eq" => member1.id)
    assert_equal_sql(
      %Q{
        SELECT "groups".* FROM "groups" WHERE ((
          "groups"."id" IN (
            SELECT "member_groups"."group_id" FROM "member_groups" WHERE "member_groups"."member_id" = #{member1.id}
          )
        ))
      },
      query.to_sql
    )
    assert_equal_groups([group1], query)
  end

  def test_seek_through_association_eq
    group1  = FactoryBot.create(:group, name: "group1", description: "desc1")
    member1 = FactoryBot.create(:member, name: "member1", groups: [group1])
    query   = Group.seek("members.id.eq" => member1.id)
    assert_equal_sql(
      %Q{
        SELECT "groups".* FROM "groups" WHERE ((
          "groups"."id" IN (
            SELECT "member_groups"."group_id" FROM "member_groups" WHERE "member_groups"."member_id" IN (
              SELECT "members"."id" FROM "members" WHERE "members"."id" = #{member1.id}
            )
          )
        ))
      },
      query.to_sql
    )
    assert_equal_groups([group1], query)
  end

end

