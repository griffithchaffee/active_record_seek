require "test_helper"

class ActiveRecordSeekTest::SeekTest < ActiveRecordSeekTest::QueryTest

  def test_seek_eq
    # records
    group1 = FactoryBot.create(:group, name: "group1")
    3.times { FactoryBot.create(:group, name: "group#{Group.count + 1}") }
    # variables
    seek_hashes  = []
    associations = %w[ groups self ]
    namespaces   = %w[ unscoped namespace ]
    # basic seek
    seek_hashes.push("name.eq" => group1.name)
    # association.name.eq
    associations.each do |association|
      seek_hashes.push("#{association}.name.eq" => group1.name)
    end
    # namespace.association.name.eq
    namespaces.each do |namespace|
      associations.each do |association|
        seek_hashes.push("#{namespace}.#{association}.name.eq" => group1.name)
      end
    end
    # assertions
    seek_hashes.each do |seek_hash|
      query = Group.seek(seek_hash)
      puts query.to_sql
      assert_equal_sql(
        %Q{SELECT "groups".* FROM "groups" WHERE ("groups"."name" = '#{group1.name}')},
        query.to_sql,
        "seek(#{seek_hash})"
      )
      assert_equal_groups([group1], query)
    end
  end

end

