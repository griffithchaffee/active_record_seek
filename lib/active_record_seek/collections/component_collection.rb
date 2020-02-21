module ActiveRecordSeek
  module Collections
    class ComponentCollection < BaseCollection

      attr_reader(*%w[ components ])

      def components_hash=(new_components_hash)
        @components = new_components_hash.map do |key, value|
          Component.new(key: key, value: value)
        end
      end

      def associations_for_query(query)
        components.map do |component|
          component.set(query: query)
        end.group_by do |component|
          component.query_association
        end.map do |association, association_components|
          AssociationComponentCollection.new(association: association, components: association_components)
        end
      end

      def apply(query)
        associations = associations_for_query(query)
        if associations.size <= 1
          associations.each do |association|
            query = association.apply(query)
          end
        else
          query = query.seek_or(self) do |this|
            this.associations_for_query(query).each do |association|
              add_query { association.apply(self) }
            end
          end
        end
        query
      end

    end
  end
end
