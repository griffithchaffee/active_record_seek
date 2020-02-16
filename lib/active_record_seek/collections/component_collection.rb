module ActiveRecordSeek
  module Collections
    class ComponentCollection < BaseCollection

      attr_reader(*%w[ components ])

      def components_hash=(new_components_hash)
        @components = new_components_hash.map do |key, value|
          Component.new(key: key, value: value)
        end
      end
=begin
      def namespaces
        components.group_by(&:namespace).map do |namespace, namespace_components|
          case namespace
          when "unscopedd"
            namespace_components.map do |namespace_component|
              NamespaceComponentCollection.new(namespace: namespace, components: [namespace_component])
            end
          else
            NamespaceComponentCollection.new(namespace: namespace, components: namespace_components)
          end
        end.flatten
      end
=end
      def associations_for_query(query)
        components.map do |component|
          component.set(query: query)
        end.group_by do |component|
          [component.query_association, component.namespace]
        end.map do |(association, namespace), association_namespace_components|
          AssociationComponentCollection.new(namespace: namespace, association: association, components: association_namespace_components)
        end
      end

      def apply(query)
        query.seek_or(self) do |this|
          this.associations_for_query(query).each do |association|
            self.enclose_with_parentheses = false
            add_query { association.apply(self) }
          end
        end
      end

    end
  end
end
