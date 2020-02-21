module ActiveRecordSeek
  module Operators
    class IlikeOperator < BaseOperator

      def arel_operation
        operation = arel_column.matches(arel_value)
        operation.case_sensitive = false
        operation
      end

    end
  end
end
