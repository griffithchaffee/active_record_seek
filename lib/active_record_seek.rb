require "byebug"
require "active_support"
require "active_support/core_ext"
require "active_record_seek/version"
require "active_record_seek/concerns/active_record_concern"
require "active_record_seek/concerns/build_concern"
require "active_record_seek/concerns/instance_variable_concern"
require "active_record_seek/scopes/base_scope"
require "active_record_seek/scopes/seek_scope"
require "active_record_seek/scopes/seek_or_scope"
require "active_record_seek/clause"
require "active_record_seek/predicate"
require "active_record_seek/operators/base_operator"
require "active_record_seek/operators/eq_operator"

ActiveSupport.on_load(:active_record) do
  # adds builder methods used to initialize seek scopes on columns of a model
  include ActiveRecordSeek::Concerns::ActiveRecordConcern
end
