module ActiveRecordSeek
  module Operators
    class NotRegexpOperator < BaseOperator

      def arel_operation
        operation = arel_column.does_not_match_regexp(arel_value)
        operation.case_sensitive = true
        operation
      end

    end
  end
end
