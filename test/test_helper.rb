$LOAD_PATH.unshift(File.expand_path("../../lib", __FILE__))
require "active_record_seek"

require "minitest/autorun"
require "factory_bot"

# defaults
require "active_record"
I18n.enforce_available_locales = false
ActiveRecord::Migration.verbose = false

# lib
require "lib/memory_database"
require "lib/memory_database_schema"
require "lib/memory_database_models"
require "lib/memory_database_factories"
require "lib/test_superclasses"
