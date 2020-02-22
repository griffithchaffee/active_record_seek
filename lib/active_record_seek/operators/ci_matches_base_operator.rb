module ActiveRecordSeek
  module Operators
    class CiMatchesBaseOperator < CiBaseOperator

    end

    {
      ci_like:       :matches,
      ci_regexp:     :matches_regexp,
      not_ci_like:   :does_not_match,
      not_ci_regexp: :does_not_match_regexp,
    }.each do |seek_operator, arel_operator|
      operator_class = Class.new(CiMatchesBaseOperator) do
        define_method(:arel_operation) do
          operation = ci_arel_column.send(arel_operator, ci_arel_value)
          operation.case_sensitive = false
          operation
        end
      end

      const_set("#{seek_operator.to_s.camelcase}Operator", operator_class)
    end

  end
end

