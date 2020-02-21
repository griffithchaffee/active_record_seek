module ActiveRecordSeek
  module Operators
    class LikeOperator < BaseOperator

      def arel_operation
        operation = arel_column.matches(arel_value)
        operation.case_sensitive = true
        operation
      end

    end
  end
end
