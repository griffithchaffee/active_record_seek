module ActiveRecordSeek
  module Operators
    class RegexpBaseOperator < BaseOperator

    end

    {
      regexp:     :matches_regexp,
      regexp_all: :matches_regexp,
      regexp_any: :matches_regexp,
      not_regexp:     :does_not_match_regexp,
      not_regexp_all: :does_not_match_regexp,
      not_regexp_any: :does_not_match_regexp,
    }.each do |seek_operator, arel_operator|
      operator_class = Class.new(RegexpBaseOperator) do
        define_method(:arel_operation) do
          operation = nil
          # must manually define _all and _any operations because arel only has matches_regexp
          if seek_operator =~ /_all\z/
            arel_value.each do |and_arel_value|
              and_operation = arel_column.send(arel_operator, and_arel_value)
              operation = operation ? operation.and(and_operation) : and_operation
            end
          elsif seek_operator =~ /_any\z/
            arel_value.each do |or_arel_value|
              or_operation = arel_column.send(arel_operator, or_arel_value)
              operation = operation ? operation.or(or_operation) : or_operation
            end
          else
            operation = arel_column.send(arel_operator, arel_value)
          end
          # switch to ~ operator
          operation.each do |operation_part|
            if operation_part.class.in?([Arel::Nodes::Regexp, Arel::Nodes::NotRegexp])
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
