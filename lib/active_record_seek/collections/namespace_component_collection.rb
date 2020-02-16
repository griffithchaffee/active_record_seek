module ActiveRecordSeek
  module Collections
    class NamespaceComponentCollection < BaseCollection

      attr_accessor(*%w[ namespace components ])

      def associations
        @associations ||= components.group_by(&:association).map do |association, association_components|
          AssociationComponentCollection.new(association: association, components: association_components)
        end
      end

      def apply(query)
        associations.each do |association|
          query = association.apply(query)
        end
        query
      end

    end
  end
end
