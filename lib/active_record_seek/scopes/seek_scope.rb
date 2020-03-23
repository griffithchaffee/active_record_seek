module ActiveRecordSeek
  module Scopes
    class SeekScope < BaseScope

      attr_reader(*%w[ seek_query active_record_query components components_hash ])

      def query=(new_query)
        @seek_query          = new_query.to_seek_query
        @active_record_query = @seek_query.to_active_record_query
        @seek_query
      end

      def components_hash=(new_components_hash)
        @components = new_components_hash.stringify_keys.map do |key, value|
          Component.new(base_query: self, key: key, value: value)
        end
      end

      def apply
        components_for_base_query = components.select(&:is_base_query_component?)
        components_by_association = components.reject(&:is_base_query_component?).group_by(&:association)
        self.query = seek_query.apply(components_for_base_query)
        self.query = active_record_query.seek_or(self) do |this|
          components_by_association.each do |association, association_components|
            add_query do
              AssociationScope.new(
                base_query:  to_seek_query,
                association: association,
                components:  association_components,
              ).apply
            end
          end
        end
        seek_query
      end

      module ActiveRecordScopeConcern

        extend ActiveSupport::Concern

        class_methods do
          def seek(components_hash = {}, &block)
            raise(ArgumentError, "#{self.class}#seek does not accept a block") if block
            SeekScope.new(
              query: all,
              components_hash: components_hash,
            ).apply.to_active_record_query
          end
        end

      end
    end
  end
end
