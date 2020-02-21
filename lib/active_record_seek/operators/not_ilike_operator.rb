module ActiveRecordSeek
  module Operators
    class NotIlikeOperator < BaseOperator

      def arel_operation
        operation = arel_column.does_not_match(arel_value)
        operation.case_sensitive = false
        operation
      end

    end
  end
end
