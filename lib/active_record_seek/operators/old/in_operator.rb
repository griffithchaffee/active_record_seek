module ActiveRecordSeek
  module Operators
    class InOperator < BaseOperator

      def arel_operation
        arel_column.send(component.operator, arel_value)
      end

    end
  end
end
