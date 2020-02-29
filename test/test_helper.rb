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
puts ""
puts Group.seek(
  "a.members.id.eq"   => 1,
  "a.members.name.eq" => "2",
  "b.members.id.eq"   => 3,
  "b.members.name.eq" => "4",
  "unscoped.members.id.eq"   => 5,
  "unscoped.members.name.eq" => "6",
  "member_groups.id.eq" => 7,
).to_sql
#=end
#byebug
#a = 1
