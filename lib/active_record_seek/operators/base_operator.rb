module ActiveRecordSeek
  module Operators
    class BaseOperator

      include Concerns::InstanceVariableConcern

      attr_accessor(*%w[ predicate ])
      delegate(*%w[ component ], to: :predicate)

      def apply
        arel_operation = predicate.arel_column.send(component.operator, predicate.arel_value)
        predicate.query.where(arel_operation)
      end

    end
  end
end
