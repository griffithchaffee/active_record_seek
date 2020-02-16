module ActiveRecordSeek
  module Collections
    class NamespaceComponentCollection < BaseCollection

      attr_accessor(*%w[ namespace components ])

      def associations_for_query(query)
        components.map do |component|
          component.set(query: query)
        end.group_by(&:query_association).map do |association, association_components|
          AssociationComponentCollection.new(namespace: namespace, association: association, components: association_components)
        end
      end

      def apply(query)
        associations_for_query(query).each do |association|
          query = association.apply(query)
        end
        query
      end

    end
  end
end
