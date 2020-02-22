module ActiveRecordSeek
  module Operators
    class NotCiEqOperator < BaseOperator

      def arel_operation
        arel_column.lower.not_eq(arel_table.lower(arel_value))
      end

    end
  end
end
