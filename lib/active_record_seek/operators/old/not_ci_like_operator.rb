module ActiveRecordSeek
  module Operators
    class NotCiLikeOperator < BaseOperator

      def arel_operation
        # SQLite does not support ILIKE
        if component.adapter_name.in?(%w[ SQLite Mysql2 ])
          operation = arel_column.lower.does_not_match(arel_table.lower(arel_value))
        else
          operation = arel_column.does_not_match(arel_value)
          operation.case_sensitive = false
          operation
        end
      end

    end
  end
end
