module ActiveRecordSeek
  module Operators
    class CiMatchesBaseOperator < CiBaseOperator

    end

    {
      ci_like:         :matches,
      ci_like_all:     :matches_all,
      ci_like_any:     :matches_any,
      not_ci_like:     :does_not_match,
      not_ci_like_all: :does_not_match_all,
      not_ci_like_any: :does_not_match_any,
    }.each do |seek_operator, arel_operator|
      operator_class = Class.new(CiMatchesBaseOperator) do
        define_method(:arel_operation) do
          operation =
            # manually LOWER for adapters without ILIKE support
            if component.adapter_name.in?(%w[ SQLite Mysql2 ])
              ci_arel_column.send(arel_operator, ci_arel_value)
            else
              arel_column.send(arel_operator, arel_value)
            end
          # switch to ILIKE if supported
          operation.each do |operation_part|
            if operation_part.class.in?([Arel::Nodes::Matches, Arel::Nodes::DoesNotMatch])
              operation_part.case_sensitive = false
            end
          end
          operation
        end
      end

      const_set("#{seek_operator.to_s.camelcase}Operator", operator_class)
    end

  end
end
