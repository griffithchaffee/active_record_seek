module ActiveRecordSeek
  module Operators
    class NotCiInOperator < BaseOperator

      def arel_operation
        ci_arel_values = arel_value.map { |value| arel_table.lower(value) }
        arel_column.lower.not_in(ci_arel_values)
      end

    end
  end
end
