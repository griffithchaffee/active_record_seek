module ActiveRecordSeek
  module Operators
    class NotIeqOperator < BaseOperator

      def arel_operation
        arel_column.lower.not_eq(arel_table.lower(arel_value))
      end

    end
  end
end
