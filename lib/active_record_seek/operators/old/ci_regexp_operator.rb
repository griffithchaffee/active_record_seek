module ActiveRecordSeek
  module Operators
    class CiRegexpOperator < BaseOperator

      def arel_operation
        operation = arel_column.matches_regexp(arel_value)
        operation.case_sensitive = false
        operation
      end

    end
  end
end
