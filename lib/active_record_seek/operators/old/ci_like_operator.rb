module ActiveRecordSeek
  module Operators
    class CiLikeOperator < BaseOperator

      def arel_operation
        # SQLite does not support ILIKE
        if component.adapter_name.in?(%w[ SQLite Mysql2 ])
          operation = arel_column.lower.matches(arel_table.lower(arel_value))
        else
          operation = arel_column.matches(arel_value)
          operation.case_sensitive = false
          operation
        end
      end

    end
  end
end
