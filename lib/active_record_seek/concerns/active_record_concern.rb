module ActiveRecordSeek
  module Concerns
    module ActiveRecordConcern

      extend ActiveSupport::Concern

      included do
        include ActiveRecordSeek::Scopes::SeekScope::ActiveRecordScopeConcern
        include ActiveRecordSeek::Scopes::SeekOrScope::ActiveRecordScopeConcern
      end

      class_methods do
        def to_seek_query
          ::ActiveRecordSeek::Query.new(active_record_query: all)
        end
      end

    end
  end
end
