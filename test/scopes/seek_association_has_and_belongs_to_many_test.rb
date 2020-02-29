require "test_helper"

class ActiveRecordSeekTest::SeekTest < ActiveRecordSeekTest::QueryTest

  def test_seek_association_has_and_belongs_to_many
    # records
    member1 = FactoryBot.create(:member, name: "member1")
    FactoryBot.create(:project, name: "project1", members: [member1])
    [nil, "unscoped", "namespace"].each do |namespace|
      seek_key   = [namespace, "members.name.eq"].compact.join(".")
      seek_value = member1.name
      seek_hash  = { seek_key => seek_value }
      query = Project.seek(seek_hash)
      assert_equal_sql(
        %Q{SELECT "projects".* FROM "projects" WHERE ("projects"."id" IN (SELECT project_id FROM "members" WHERE ("members"."name" = 'member1')))},
        query.to_sql,
        "seek(#{seek_hash})"
      )
      assert_raises(ActiveRecord::StatementInvalid) do
        query.to_a
      end
    end
  end

end
