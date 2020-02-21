module ActiveRecordSeek
  module Operators
    class BaseOperator

      include Concerns::InstanceVariableConcern

      attr_accessor(*%w[ component query ])
      attr_writer(*%w[ arel_table arel_column arel_value ])

      def arel_table
        query.arel_table
      end

      def arel_column
        arel_table[component.column]
      end

      def arel_value
        component.value
      end

      def arel_operation
        arel_column.send(component.operator, arel_value)
      end

      def apply(query)
        set(query: query)
        query.where(arel_operation)
      end

    end
  end
end
