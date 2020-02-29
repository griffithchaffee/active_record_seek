module ActiveRecordSeek
  module Scopes
    class SeekScope < BaseScope

      attr_reader(*%w[ components ])

      def components_hash=(new_components_hash)
        @components = Collections::ComponentCollection.new(components_hash: new_components_hash)
      end

      def apply(query)
        components.apply(query.to_seek_query)
      end

      module ActiveRecordScopeConcern

        extend ActiveSupport::Concern

        class_methods do
          def seek(components_hash = {}, &block)
            raise(ArgumentError, "#{self.class}#seek does not accept a block") if block
            SeekScope.new(components_hash: components_hash).apply(all).to_active_record_query
          end
        end

      end

    end
  end
end
