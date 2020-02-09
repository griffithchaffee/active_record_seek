module ActiveRecordSeek
  module Concerns
    module InstanceVariableConcern

      extend ActiveSupport::Concern

      def instance_variable_reset(variable, &block)
        if instance_variable_defined?(variable)
          remove_instance_variable(variable)
          true
        else
          false
        end
      end

      def instance_variable_yield(variable)
        if instance_variable_defined?(variable)
          value = instance_variable_get(variable)
          yield(value)
          value
        end
      end

    end
  end
end
