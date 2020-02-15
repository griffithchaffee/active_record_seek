module ActiveRecordSeek
  module Collections
    class NamespaceComponentCollection < BaseCollection

      attr_accessor(*%w[ namespace components ])

      def association_query(query)
        case namespace
        when "self" then query
        else query
        end
      end

      def apply(query)
        namespace_query = association_query(query)
        components.each do |component|
          namespace_query = component.apply(namespace_query)
        end
        namespace_query
      end

    end
  end
end
