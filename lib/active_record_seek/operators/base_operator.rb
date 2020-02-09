module ActiveRecordSeek
  module Operators
    class BaseOperator

      include Concerns::BuildConcern
      include Concerns::InstanceVariableConcern

      attr_accessor(*%w[ predicate ])

      def arel_value
        predicate.value
      end

      def apply
        arel_operation = predicate.arel_column.send(predicate.operator, arel_value)
        predicate.clause.where(arel_operation)
      end

    end
  end
end
