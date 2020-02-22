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

    %w[
      eq
      eq_all
      eq_any
      gt
      gt_all
      gt_any
      gteq
      gteq_all
      gteq_any
      in
      in_all
      in_any
      lt
      lt_all
      lt_any
      lteq
      lteq_all
      lteq_any
      not_eq
      not_eq_all
      not_eq_any
      not_in
      not_in_all
      not_in_any
    ].each do |operator|
      const_set("#{operator.camelcase}Operator", Class.new(BaseOperator))
    end
  end
end

