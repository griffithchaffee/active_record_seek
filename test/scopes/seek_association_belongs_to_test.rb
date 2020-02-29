require "test_helper"

class ActiveRecordSeekTest::SeekTest < ActiveRecordSeekTest::QueryTest

  def test_seek_association_belongs_to
    # records
    group1 = FactoryBot.create(:group, name: "group1")
    group2 = FactoryBot.create(:group, name: "group2")
    member_group1 = FactoryBot.create(:member_group, group: group1)
    FactoryBot.create(:member_group, group: group2)
    # variables
    seek_hashes  = []
    namespaces   = %w[ unscoped namespace ]
    # association.name.eq
    seek_hashes.push("group.name.eq" => group1.name)
    # namespace.association.name.eq
    namespaces.each do |namespace|
      seek_hashes.push("#{namespace}.group.name.eq" => group1.name)
    end
    # assertions
    seek_hashes.each do |seek_hash|
      query = MemberGroup.seek(seek_hash)
      assert_equal_sql(
        %Q{SELECT "member_groups".* FROM "member_groups" WHERE ("member_groups"."group_id" IN (SELECT "groups"."id" FROM "groups" WHERE ("groups"."name" = '#{group1.name}')))},
        query.to_sql,
        "seek(#{seek_hash})"
      )
      assert_equal_records([member_group1], query)
      assert_equal_records([group1], query.map(&:group))
    end
  end

end
