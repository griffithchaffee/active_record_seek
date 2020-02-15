module ActiveRecordSeek
  module Collections
    class ComponentCollection < BaseCollection

      attr_reader(*%w[
        original_components_hash
        components
      ])

      def components_hash=(new_components_hash)
        @original_components_hash = new_components_hash
        @components = new_components_hash.map do |key, value|
          Component.new(key: key, value: value)
        end
      end

      def namespaces
        @namespaces ||= components.group_by(&:namespace).map do |namespace, namespace_components|
          NamespaceComponentCollection.new(namespace: namespace, components: namespace_components)
        end
      end

    end
  end
end
