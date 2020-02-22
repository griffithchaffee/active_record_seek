module ActiveRecordSeek
  module Operators
    class CiBaseOperator < BaseOperator

      def ci_arel_column
        arel_column.lower
      end

      def ci_arel_value(value = arel_value)
        if value.is_a?(Array)
          value.map { |v| ci_arel_value(v) }
        elsif value.is_a?(String)
          arel_table.lower(value)
        else
          value
        end
      end

      def arel_operation
        ci_arel_column.send(component.operator, ci_arel_value)
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
    ].to_h do |operator|
      [
        operator.gsub(/\A(not_)?/, '\1ci_'),
        operator,
      ]
    end.each do |seek_operator, arel_operator|
      operator_class = Class.new(CiBaseOperator) do
        define_method(:arel_operation) do
          ci_arel_column.send(arel_operator, ci_arel_value)
        end
      end

      const_set("#{seek_operator.to_s.camelcase}Operator", operator_class)
    end
  end
end

