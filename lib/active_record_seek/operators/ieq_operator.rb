module ActiveRecordSeek
  module Operators
    class IeqOperator < BaseOperator

      def arel_operation
        arel_column.lower.eq(arel_table.lower(arel_value))
      end

    end
  end
end
