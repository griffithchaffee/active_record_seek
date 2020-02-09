module ActiveRecordSeek
  module Concerns
    module ActiveRecordConcern

      extend ActiveSupport::Concern

      class_methods do
        # apply seek query
        def seek(*params, &block)
          Scopes::SeekScope.build(query: all).apply(*params, &block)
        end

        # apply seek OR query
        def seek_or(*params, &block)
          Scopes::SeekOrScope.build(query: all).apply(*params, &block)
        end
      end

    end
  end
end
