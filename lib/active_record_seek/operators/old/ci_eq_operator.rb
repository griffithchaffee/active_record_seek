module ActiveRecordSeek
  module Operators
    class CiEqOperator < BaseOperator

      def arel_operation
        arel_column.lower.eq(arel_table.lower(arel_value))
      end

    end
  end
end
