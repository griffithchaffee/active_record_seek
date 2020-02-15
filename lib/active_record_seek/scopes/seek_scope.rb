module ActiveRecordSeek
  module Scopes
    class SeekScope < BaseScope

      attr_reader(*%w[ components ])

      def components_hash=(new_components_hash)
        @components = Collections::ComponentCollection.new(components_hash: new_components_hash)
      end

      def apply(query)
        query.seek_or(self) do |this|
          this.components.namespaces.each do |namespace|
            add_query do |unscoped|
              namespace.apply(unscoped)
            end
          end
        end
      end

      module ActiveRecordScopeConcern

        extend ActiveSupport::Concern

        class_methods do
          def seek(components_hash = {}, &block)
            raise(ArgumentError, "#{self.class}#seek does not accept a block") if block
            SeekScope.new(components_hash: components_hash).apply(all)
          end
        end

      end

    end
  end
end
