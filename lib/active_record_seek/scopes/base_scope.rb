# WHERE (clause) has many conditions (predicates)
module ActiveRecordSeek
  module Scopes
    class BaseScope

      include Concerns::BuildConcern
      include Concerns::InstanceVariableConcern

      attr_reader(*%w[ query ])

      def query=(new_query)
        @query = new_query.all
      end

      def model
        query.klass
      end

      def apply
        raise(RuntimeError, %Q{subclasses of #{self.class} must define their own "apply" method})
      end
    end
  end
end
