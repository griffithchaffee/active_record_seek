module ActiveRecordSeek
  module Operators
    class RegexpOperator < BaseOperator

      def arel_operation
        operation = arel_column.matches_regexp(arel_value)
        operation.case_sensitive = true
        operation
      end

    end
  end
end
