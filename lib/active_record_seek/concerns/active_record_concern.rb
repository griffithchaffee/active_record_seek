module ActiveRecordSeek
  module Concerns
    module ActiveRecordConcern

      extend ActiveSupport::Concern

      included do
        ::ActiveRecordSeek::Scopes::BaseScope.subclasses.each do |subclass|
          include subclass::ActiveRecordScopeConcern
        end
      end

      class_methods do
        def to_seek_query
          ::ActiveRecordSeek::Query.new(query: all)
        end
      end

    end
  end
end
