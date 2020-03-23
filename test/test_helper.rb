#$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))
require "active_record_seek"

require "minitest/autorun"
require "factory_bot"

# defaults
require "active_record"
I18n.enforce_available_locales = false
ActiveRecord::Migration.verbose = false

# lib
require "bundler"
require "lib/test_env"
require "lib/adapter_database"
require "lib/adapter_database_schema"

AdapterDatabase.instance.recreate_database!
AdapterDatabase.instance.connect!
AdapterDatabase.instance.write_schema!
puts "DatabaseAdapter: #{AdapterDatabase.instance.adapter_name}"

require "lib/adapter_database_models"
require "lib/adapter_database_factories"
require "lib/test_superclasses"

#=begin
query = Group.seek(
  "a.members.id.eq"   => 1,
  "a.members.name.eq" => "2",
  "b.members.id.eq"   => 3,
  "b.members.name.eq" => "4",
  "unscoped.members.id.eq"   => 5,
  "unscoped.members.name.eq" => "6",
  "member_groups.id.eq" => 7,
)
expected_sql = %Q{SELECT "groups".* FROM "groups" WHERE (("groups"."id" IN (SELECT "member_groups"."group_id" FROM "member_groups" WHERE "member_groups"."member_id" IN (SELECT "members"."id" FROM "members" WHERE (("members"."id" = 1 AND "members"."name" = '2') OR ("members"."id" = 3 AND "members"."name" = '4') OR ("members"."id" = 5) OR ("members"."name" = '6'))))) OR ("groups"."id" IN (SELECT "member_groups"."group_id" FROM "member_groups" WHERE ("member_groups"."id" = 7))))}
#=end
if AdapterDatabase.instance.adapter_name != "Mysql2" && query.to_sql != expected_sql
  puts ""
  puts "ERROR - example query does not match expected SQL"
  puts ""
  puts "EXPECT: #{expected_sql}"
  puts ""
  puts "ACTUAL: #{query.to_sql}"
  puts ""
  byebug
end
