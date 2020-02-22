module ActiveRecordSeek
  module Operators
    class NotLikeOperator < BaseOperator

      def arel_operation
        operation = arel_column.does_not_match(arel_value)
        operation.case_sensitive = true
        operation
      end

    end
  end
end
