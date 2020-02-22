module ActiveRecordSeek
  module Operators
    class MatchesBaseOperator < BaseOperator

    end

    {
      like:       :matches,
      regexp:     :matches_regexp,
      not_like:   :does_not_match,
      not_regexp: :does_not_match_regexp,
    }.each do |seek_operator, arel_operator|
      operator_class = Class.new(MatchesBaseOperator) do
        define_method(:arel_operation) do
          operation = arel_column.send(arel_operator, arel_value)
          operation.case_sensitive = true
          operation
        end
      end

      const_set("#{seek_operator.to_s.camelcase}Operator", operator_class)
    end

  end
end
