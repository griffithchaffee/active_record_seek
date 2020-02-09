module ActiveRecordSeek
  module Scopes
    class SeekScope < BaseScope

      attr_reader(*%w[ predicates_hash ])

      def predicates
        instance_variable_yield(:@predicates) { |value| return value }
        @predicates = predicates_hash.map do |predicate_key, predicate_value|
          Predicate.build(key: predicate_key, value: predicate_value)
        end
      end

      def predicates_hash=(new_predicates_hash)
        instance_variable_reset(:@predicates)
        @predicates_hash = new_predicates_hash
      end

      def apply(predicates_hash = {}, &block)
        raise(ArgumentError, "#{self.class}.apply does not accept a block") if block
        set(predicates_hash: predicates_hash)
        query.seek_or(self) do |this|
          # build array of namespace queries to combined into one OR query
          this.predicates.group_by(&:namespace).each do |namespace, namespace_predicates|
            add_clause do |clause|
              namespace_predicates.each do |namespace_predicate|
                clause = namespace_predicate.apply(clause)
              end
              clause
            end
          end
        end
      end

    end
  end
end
