module ActiveRecordSeek
  module Operators
    class NotCiRegexpOperator < BaseOperator

      def arel_operation
        operation = arel_column.does_not_match_regexp(arel_value)
        operation.case_sensitive = false
        operation
      end

    end
  end
end
