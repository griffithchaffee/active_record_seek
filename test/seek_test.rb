require "test_helper"
require "support/database_models"

class ActiveRecordSeek::SeekTest < ActiveRecordSeek::ModelTest

  def test_seek_on_attributes
    group1 = FactoryGirl.create(:group, name: "group1", description: "desc1")
    group2 = FactoryGirl.create(:group, name: "group2", description: "desc2")
    # assertions
    assert_sql = -> (expected_where_sql, actual, options = {}) do
      options = options.with_indifferent_access.assert_valid_keys(*%w[ wrap ])
      actual_sql = actual.to_sql
      expected_sql = %Q[SELECT "groups".* FROM "groups"]
      if expected_where_sql.present?
        expected_sql << " WHERE " + ("(" * options[:wrap].to_i) + expected_where_sql + (")" * options[:wrap].to_i)
      end
      puts expected_sql, actual_sql if expected_sql != actual_sql
      assert_equal expected_sql, actual_sql, caller.select { |l| l.starts_with?(File.dirname(__FILE__)) }.join("\n")
    end
    # verify parentheses wrapping
    where_sql = %Q[("groups"."id" = #{group1.id}) AND ("groups"."name" = '#{group1.name}') AND ("groups"."id" = #{group2.id}) AND ("groups"."name" = '#{group2.name}')]
    assert_sql.call where_sql, Group.where_id(eq: group1.id).where_name(eq: group1.name).where_id(eq: group2.id).where_name(eq: group2.name), wrap: 0
    where_sql = %Q[(("groups"."id" = #{group1.id}) AND ("groups"."name" = '#{group1.name}')) AND (("groups"."id" = #{group2.id}) AND ("groups"."name" = '#{group2.name}'))]
    assert_sql.call where_sql, Group.seek(id_eq: group1.id, name_eq: group1.name).seek(id_eq: group2.id, name_eq: group2.name), wrap: 0
    assert_sql.call where_sql, Group.search(id_eq: group1.id, name_eq: group1.name).search(id_eq: group2.id, name_eq: group2.name), wrap: 0
    # eq and NEVER NULL
    where_sql = %Q["groups"."name" = '#{group1.name}']
    assert_sql.call where_sql, Group.where_name(eq: group1.name), wrap: 1
    assert_sql.call where_sql, Group.seek(name_eq: group1.name), wrap: 2
    assert_sql.call where_sql, Group.search(name_eq: group1.name), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_name(eq: group1), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(name_eq: group1), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(name_eq: group1), wrap: 2 }
    where_sql = %Q["groups"."name" IS NULL]
    assert_sql.call where_sql, Group.where_name(eq: nil), wrap: 1
    assert_sql.call where_sql, Group.seek(name_eq: nil), wrap: 2
    assert_sql.call %Q[], Group.search(name_eq: nil), wrap: 2
    assert_sql.call %Q[], Group.search(name_eq: ""), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_name(eq: Group.new), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(name_eq: Group.new), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(name_eq: Group.new), wrap: 2 }
    # eq and ALLOW NULL
    where_sql = %Q["groups"."description" = '#{group1.description}']
    assert_sql.call where_sql, Group.where_description(eq: group1.description), wrap: 1
    assert_sql.call where_sql, Group.seek(description_eq: group1.description), wrap: 2
    assert_sql.call where_sql, Group.search(description_eq: group1.description), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_description(eq: group1), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(description_eq: group1), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(description_eq: group1), wrap: 2 }
    where_sql = %Q["groups"."description" IS NULL]
    assert_sql.call where_sql, Group.where_description(eq: nil), wrap: 1
    assert_sql.call where_sql, Group.seek(description_eq: nil), wrap: 2
    assert_sql.call %Q[], Group.search(description_eq: nil), wrap: 2
    assert_sql.call %Q[], Group.search(description_eq: ""), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_description(eq: Group.new), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(description_eq: Group.new), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(description_eq: Group.new), wrap: 2 }
    # not_eq and NEVER NULL
    where_sql = %Q["groups"."name" != '#{group1.name}']
    assert_sql.call where_sql, Group.where_name(not_eq: group1.name), wrap: 1
    assert_sql.call where_sql, Group.seek(name_not_eq: group1.name), wrap: 2
    assert_sql.call where_sql, Group.search(name_not_eq: group1.name), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_name(not_eq: group1), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(name_not_eq: group1), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(name_not_eq: group1), wrap: 2 }
    where_sql = %Q["groups"."name" IS NOT NULL]
    assert_sql.call where_sql, Group.where_name(not_eq: nil), wrap: 1
    assert_sql.call where_sql, Group.seek(name_not_eq: nil), wrap: 2
    assert_sql.call %Q[], Group.search(name_not_eq: nil), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_name(not_eq: Group.new), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(name_not_eq: Group.new), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(name_not_eq: Group.new), wrap: 2 }
    # not_eq and ALLOW NULL
    where_sql = %Q["groups"."description" != '#{group1.description}']
    assert_sql.call where_sql, Group.where_description(not_eq: group1.description), wrap: 1
    assert_sql.call where_sql, Group.seek(description_not_eq: group1.description), wrap: 2
    assert_sql.call where_sql, Group.search(description_not_eq: group1.description), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_description(not_eq: group1), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(description_not_eq: group1), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(description_not_eq: group1), wrap: 2 }
    where_sql = %Q["groups"."description" IS NOT NULL]
    assert_sql.call where_sql, Group.where_description(not_eq: nil), wrap: 1
    assert_sql.call where_sql, Group.seek(description_not_eq: nil), wrap: 2
    assert_sql.call %Q[], Group.search(description_not_eq: nil), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_description(not_eq: Group.new), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(description_not_eq: Group.new), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(description_not_eq: Group.new), wrap: 2 }
    # ieq and NEVER NULL
    where_sql = %Q[LOWER("groups"."name") = LOWER('#{group1.name}')]
    assert_sql.call where_sql, Group.where_name(ieq: group1.name), wrap: 1
    assert_sql.call where_sql, Group.seek(name_ieq: group1.name), wrap: 2
    assert_sql.call where_sql, Group.search(name_ieq: group1.name), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_name(ieq: group1), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(name_ieq: group1), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(name_ieq: group1), wrap: 2 }
    where_sql = %Q["groups"."name" IS NULL]
    assert_sql.call where_sql, Group.where_name(ieq: nil), wrap: 1
    assert_sql.call where_sql, Group.seek(name_ieq: nil), wrap: 2
    assert_sql.call %Q[], Group.search(name_ieq: nil), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_name(ieq: Group.new), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(name_ieq: Group.new), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(name_ieq: Group.new), wrap: 2 }
    # ieq and ALLOW NULL
    where_sql = %Q[LOWER("groups"."description") = LOWER('#{group1.description}')]
    assert_sql.call where_sql, Group.where_description(ieq: group1.description), wrap: 1
    assert_sql.call where_sql, Group.seek(description_ieq: group1.description), wrap: 2
    assert_sql.call where_sql, Group.search(description_ieq: group1.description), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_description(ieq: group1), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(description_ieq: group1), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(description_ieq: group1), wrap: 2 }
    where_sql = %Q["groups"."description" IS NULL]
    assert_sql.call where_sql, Group.where_description(ieq: nil), wrap: 1
    assert_sql.call where_sql, Group.seek(description_ieq: nil), wrap: 2
    assert_sql.call %Q[], Group.search(description_ieq: nil), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_description(ieq: Group.new), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(description_ieq: Group.new), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(description_ieq: Group.new), wrap: 2 }
    # not_ieq and NEVER NULL
    where_sql = %Q[LOWER("groups"."name") != LOWER('#{group1.name}')]
    assert_sql.call where_sql, Group.where_name(not_ieq: group1.name), wrap: 1
    assert_sql.call where_sql, Group.seek(name_not_ieq: group1.name), wrap: 2
    assert_sql.call where_sql, Group.search(name_not_ieq: group1.name), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_name(not_ieq: group1), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(name_not_ieq: group1), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(name_not_ieq: group1), wrap: 2 }
    where_sql = %Q["groups"."name" IS NOT NULL]
    assert_sql.call where_sql, Group.where_name(not_ieq: nil), wrap: 1
    assert_sql.call where_sql, Group.seek(name_not_ieq: nil), wrap: 2
    assert_sql.call %Q[], Group.search(name_not_ieq: nil), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_name(not_ieq: Group.new), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(name_not_ieq: Group.new), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(name_not_ieq: Group.new), wrap: 2 }
    # not_ieq and ALLOW NULL
    where_sql = %Q[LOWER("groups"."description") != LOWER('#{group1.description}')]
    assert_sql.call where_sql, Group.where_description(not_ieq: group1.description), wrap: 1
    assert_sql.call where_sql, Group.seek(description_not_ieq: group1.description), wrap: 2
    assert_sql.call where_sql, Group.search(description_not_ieq: group1.description), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_description(not_ieq: group1), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(description_not_ieq: group1), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(description_not_ieq: group1), wrap: 2 }
    where_sql = %Q["groups"."description" IS NOT NULL]
    assert_sql.call where_sql, Group.where_description(not_ieq: nil), wrap: 1
    assert_sql.call where_sql, Group.seek(description_not_ieq: nil), wrap: 2
    assert_sql.call %Q[], Group.search(description_not_ieq: nil), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_description(not_ieq: Group.new), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(description_not_ieq: Group.new), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(description_not_ieq: Group.new), wrap: 2 }
    # matches and NEVER NULL
    where_sql = %Q["groups"."name" LIKE '%#{group1.name}%']
    assert_sql.call where_sql, Group.where_name(matches: group1.name), wrap: 1
    assert_sql.call where_sql, Group.seek(name_matches: group1.name), wrap: 2
    assert_sql.call where_sql, Group.search(name_matches: group1.name), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_name(matches: group1), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(name_matches: group1), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(name_matches: group1), wrap: 2 }
    where_sql = %Q[]
    assert_sql.call where_sql, Group.where_name(matches: ""), wrap: 1
    assert_sql.call where_sql, Group.seek(name_matches: ""), wrap: 2
    assert_sql.call where_sql, Group.search(name_matches: ""), wrap: 2
    assert_sql.call where_sql, Group.where_name(matches: nil), wrap: 1
    assert_sql.call where_sql, Group.seek(name_matches: nil), wrap: 2
    assert_sql.call where_sql, Group.search(name_matches: nil), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_name(matches: Group.new), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(name_matches: Group.new), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(name_matches: Group.new), wrap: 2 }
    # matches and ALLOW NULL
    where_sql = %Q["groups"."description" LIKE '%#{group1.description}%']
    assert_sql.call where_sql, Group.where_description(matches: group1.description), wrap: 1
    assert_sql.call where_sql, Group.seek(description_matches: group1.description), wrap: 2
    assert_sql.call where_sql, Group.search(description_matches: group1.description), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_description(matches: group1), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(description_matches: group1), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(description_matches: group1), wrap: 2 }
    where_sql = %Q[]
    assert_sql.call where_sql, Group.where_description(matches: ""), wrap: 1
    assert_sql.call where_sql, Group.seek(description_matches: ""), wrap: 2
    assert_sql.call where_sql, Group.search(description_matches: ""), wrap: 2
    assert_sql.call where_sql, Group.where_description(matches: nil), wrap: 1
    assert_sql.call where_sql, Group.seek(description_matches: nil), wrap: 2
    assert_sql.call where_sql, Group.search(description_matches: nil), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_description(matches: Group.new), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(description_matches: Group.new), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(description_matches: Group.new), wrap: 2 }
    # does_not_match and NEVER NULL
    where_sql = %Q["groups"."name" NOT LIKE '%#{group1.name}%']
    assert_sql.call where_sql, Group.where_name(does_not_match: group1.name), wrap: 1
    assert_sql.call where_sql, Group.seek(name_does_not_match: group1.name), wrap: 2
    assert_sql.call where_sql, Group.search(name_does_not_match: group1.name), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_name(does_not_match: group1), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(name_does_not_match: group1), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(name_does_not_match: group1), wrap: 2 }
    where_sql = %Q[1=0]
    assert_sql.call where_sql, Group.where_name(does_not_match: ""), wrap: 1
    assert_sql.call where_sql, Group.seek(name_does_not_match: ""), wrap: 2
    assert_sql.call %Q[], Group.search(name_does_not_match: ""), wrap: 2
    assert_sql.call where_sql, Group.where_name(does_not_match: nil), wrap: 1
    assert_sql.call where_sql, Group.seek(name_does_not_match: nil), wrap: 2
    assert_sql.call %Q[], Group.search(name_does_not_match: nil), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_name(does_not_match: Group.new), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(name_does_not_match: Group.new), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(name_does_not_match: Group.new), wrap: 2 }
    # does_not_match and ALLOW NULL
    where_sql = %Q["groups"."description" NOT LIKE '%#{group1.description}%']
    assert_sql.call where_sql, Group.where_description(does_not_match: group1.description), wrap: 1
    assert_sql.call where_sql, Group.seek(description_does_not_match: group1.description), wrap: 2
    assert_sql.call where_sql, Group.search(description_does_not_match: group1.description), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_description(does_not_match: group1), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(description_does_not_match: group1), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(description_does_not_match: group1), wrap: 2 }
    where_sql = %Q[1=0]
    assert_sql.call where_sql, Group.where_description(does_not_match: ""), wrap: 1
    assert_sql.call where_sql, Group.seek(description_does_not_match: ""), wrap: 2
    assert_sql.call %Q[], Group.search(description_does_not_match: ""), wrap: 2
    assert_sql.call where_sql, Group.where_description(does_not_match: nil), wrap: 1
    assert_sql.call where_sql, Group.seek(description_does_not_match: nil), wrap: 2
    assert_sql.call %Q[], Group.search(description_does_not_match: nil), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_description(does_not_match: Group.new), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(description_does_not_match: Group.new), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(description_does_not_match: Group.new), wrap: 2 }
    # in and NEVER NULL
    where_sql = %Q["groups"."name" IN ('#{group1.name}', '#{group2.name}')]
    assert_sql.call where_sql, Group.where_name(in: [group1.name, group2.name]), wrap: 1
    assert_sql.call where_sql, Group.seek(name_in: [group1.name, group2.name]), wrap: 2
    assert_sql.call where_sql, Group.search(name_in: [group1.name, group2.name]), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_name(in: [group1, group2]), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(name_in: [group1, group2]), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(name_in: [group1, group2]), wrap: 2 }
    assert_sql.call where_sql, Group.where_name(in: [group1.name, group2.name, nil]), wrap: 1
    assert_sql.call where_sql, Group.seek(name_in: [group1.name, group2.name, nil]), wrap: 2
    assert_sql.call where_sql, Group.search(name_in: [group1.name, group2.name, nil]), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_name(in: [Group.new]), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(name_in: [Group.new]), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(name_in: [Group.new]), wrap: 2 }
    # in and ALLOW NULL
    where_sql = %Q["groups"."description" IN ('#{group1.description}', '#{group2.description}')]
    assert_sql.call where_sql, Group.where_description(in: [group1.description, group2.description]), wrap: 1
    assert_sql.call where_sql, Group.seek(description_in: [group1.description, group2.description]), wrap: 2
    assert_sql.call where_sql, Group.search(description_in: [group1.description, group2.description]), wrap: 2
    assert_sql.call where_sql, Group.search(description_in: [group1.description, group2.description, nil]), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_description(in: [group1, group2]), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(description_in: [group1, group2]), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(description_in: [group1, group2]), wrap: 2 }
    where_sql = %Q[(("groups"."description" IS NULL)) OR (("groups"."description" IN ('#{group1.description}', '#{group2.description}')))]
    assert_sql.call where_sql, Group.where_description(in: [group1.description, group2.description, nil]), wrap: 1
    assert_sql.call where_sql, Group.seek(description_in: [group1.description, group2.description, nil]), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_description(in: [Group.new]), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(description_in: [Group.new]), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(description_in: [Group.new]), wrap: 2 }
    # not_in and NEVER NULL
    where_sql = %Q["groups"."name" NOT IN ('#{group1.name}', '#{group2.name}')]
    assert_sql.call where_sql, Group.where_name(not_in: [group1.name, group2.name]), wrap: 1
    assert_sql.call where_sql, Group.seek(name_not_in: [group1.name, group2.name]), wrap: 2
    assert_sql.call where_sql, Group.search(name_not_in: [group1.name, group2.name]), wrap: 2
    assert_sql.call where_sql, Group.search(name_not_in: [group1.name, group2.name, nil]), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_name(not_in: [group1, group2]), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(name_not_in: [group1, group2]), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(name_not_in: [group1, group2]), wrap: 2 }
    assert_sql.call where_sql, Group.where_name(not_in: [group1.name, group2.name, nil]), wrap: 1
    assert_sql.call where_sql, Group.seek(name_not_in: [group1.name, group2.name, nil]), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_name(not_in: [Group.new]), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(name_not_in: [Group.new]), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(name_not_in: [Group.new]), wrap: 2 }
    # not_in and ALLOW NULL
    where_sql = %Q[(("groups"."description" IS NULL)) OR (("groups"."description" NOT IN ('#{group1.description}', '#{group2.description}')))]
    assert_sql.call where_sql, Group.where_description(not_in: [group1.description, group2.description]), wrap: 1
    assert_sql.call where_sql, Group.seek(description_not_in: [group1.description, group2.description]), wrap: 2
    assert_sql.call where_sql, Group.search(description_not_in: [group1.description, group2.description]), wrap: 2
    assert_sql.call where_sql, Group.search(description_not_in: [group1.description, group2.description, nil]), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_description(not_in: [group1, group2]), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(description_not_in: [group1, group2]), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(description_not_in: [group1, group2]), wrap: 2 }
    where_sql = %Q["groups"."description" NOT IN ('#{group1.description}', '#{group2.description}')) AND ("groups"."description" IS NOT NULL]
    assert_sql.call where_sql, Group.where_description(not_in: [group1.description, group2.description, nil]), wrap: 1
    assert_sql.call where_sql, Group.seek(description_not_in: [group1.description, group2.description, nil]), wrap: 2
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_description(not_in: [Group.new]), wrap: 1 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek(description_not_in: [Group.new]), wrap: 2 }
    assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search(description_not_in: [Group.new]), wrap: 2 }
    # lt lteq gt gteq
    { lt: "<", lteq: "<=", gt: ">", gteq: ">=" }.each do |operator, operator_sql|
      # NEVER NULL
      where_sql = %Q["groups"."id" #{operator_sql} #{group1.id}]
      assert_sql.call where_sql, Group.where_id(operator => group1.id), wrap: 1
      assert_sql.call where_sql, Group.seek("id_#{operator}" => group1.id), wrap: 2
      assert_sql.call where_sql, Group.search("id_#{operator}" => group1.id), wrap: 2
      assert_sql.call %Q[], Group.search("id_#{operator}" => nil), wrap: 2
      assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_id(operator => group1), wrap: 1 }
      assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek("id_#{operator}" => group1), wrap: 2 }
      assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search("id_#{operator}" => group1), wrap: 2 }
      assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_id(operator => Group.new), wrap: 1 }
      assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek("id_#{operator}" => Group.new), wrap: 2 }
      assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search("id_#{operator}" => Group.new), wrap: 2 }
      assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_id(operator => nil), wrap: 1 }
      assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek("id_#{operator}" => nil), wrap: 2 }
      # ALLOW NULL
      where_sql = %Q["groups"."max_members" #{operator_sql} #{group1.id}]
      assert_sql.call where_sql, Group.where_max_members(operator => group1.id), wrap: 1
      assert_sql.call where_sql, Group.seek("max_members_#{operator}" => group1.id), wrap: 2
      assert_sql.call where_sql, Group.search("max_members_#{operator}" => group1.id), wrap: 2
      assert_sql.call %Q[], Group.search("max_members_#{operator}" => nil), wrap: 2
      assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_max_members(operator => group1), wrap: 1 }
      assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek("max_members_#{operator}" => group1), wrap: 2 }
      assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search("max_members_#{operator}" => group1), wrap: 2 }
      assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_max_members(operator => Group.new), wrap: 1 }
      assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek("max_members_#{operator}" => Group.new), wrap: 2 }
      assert_raises(ArgumentError) { assert_sql.call where_sql, Group.search("max_members_#{operator}" => Group.new), wrap: 2 }
      assert_raises(ArgumentError) { assert_sql.call where_sql, Group.where_max_members(operator => nil), wrap: 1 }
      assert_raises(ArgumentError) { assert_sql.call where_sql, Group.seek("max_members_#{operator}" => nil), wrap: 2 }
    end
  end

end

