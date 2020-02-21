require "byebug"
require "active_support"
require "active_support/core_ext"
require "active_record_seek/version"
# concerns
require "active_record_seek/concerns/instance_variable_concern"
# core
require "active_record_seek/query"
require "active_record_seek/component"
#require "active_record_seek/predicate"
# collections
require "active_record_seek/collections/base_collection"
require "active_record_seek/collections/component_collection"
require "active_record_seek/collections/namespace_component_collection"
require "active_record_seek/collections/association_component_collection"
# operators
require "active_record_seek/operators/base_operator"
require "active_record_seek/operators/eq_operator"
require "active_record_seek/operators/ieq_operator"
require "active_record_seek/operators/like_operator"
require "active_record_seek/operators/ilike_operator"
require "active_record_seek/operators/not_eq_operator"
require "active_record_seek/operators/not_ieq_operator"
require "active_record_seek/operators/not_like_operator"
require "active_record_seek/operators/not_ilike_operator"
# scopes
require "active_record_seek/scopes/base_scope"
require "active_record_seek/scopes/seek_scope"
require "active_record_seek/scopes/seek_or_scope"
# callbacks
require "active_record_seek/concerns/active_record_concern"

ActiveSupport.on_load(:active_record) do
  # adds builder methods used to initialize seek scopes on columns of a model
  include ActiveRecordSeek::Concerns::ActiveRecordConcern
end
