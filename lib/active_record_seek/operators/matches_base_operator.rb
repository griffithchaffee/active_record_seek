module ActiveRecordSeek
  module Operators
    class MatchesBaseOperator < BaseOperator

    end

    {
      like:         :matches,
      like_all:     :matches_all,
      like_any:     :matches_any,
      not_like:     :does_not_match,
      not_like_all: :does_not_match_all,
      not_like_any: :does_not_match_any,
    }.each do |seek_operator, arel_operator|
      operator_class = Class.new(MatchesBaseOperator) do
        define_method(:arel_operation) do
          operation = arel_column.send(arel_operator, arel_value)
          # switch to LIKE operator
          operation.each do |operation_part|
            if operation_part.class.in?([Arel::Nodes::Matches, Arel::Nodes::DoesNotMatch])
              operation_part.case_sensitive = true
            end
          end
          operation
        end
      end

      const_set("#{seek_operator.to_s.camelcase}Operator", operator_class)
    end

  end
end
