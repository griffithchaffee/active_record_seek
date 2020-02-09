module ActiveRecordSeek
  class Operator
    attr_accessor :operator, :matcher, :case_insensitive

    def initialize(operator:, matcher:, case_insensitive: false, value_mutator: nil)
      self.operator         = operator.to_sym
      self.matcher          = matcher
      self.case_insensitive = case_insensitive
    end

    def match?(column_and_operator)
      column_and_operator =~ matcher || column_and_operator.to_sym == operator ? true : false
    end

    def parse_column(column_and_operator)
      column_and_operator.to_sym == operator ? nil : column_and_operator.remove(matcher)
    end

    class << self
      def operators
        @operators ||= []
      end

      def add(*params, &block)
        new_operator = new(*params, &block)
        operators << new_operator
        # need to sort operators for correct matching order
        operators.sort_by! { |operator| -operator.operator.length }
      end

      def find_by_match(column_and_operator)
        column_and_operator = column_and_operator.to_s
        operators.find { |operator| operator.match?(column_and_operator) }
      end

      def find_by_match!(column_and_operator)
        matched_operator = find_by_match(column_and_operator)
        return matched_operator if matched_operator
        raise ArgumentError, "unable to find operator for #{column_and_operator.inspect} - Available: #{operators.map(&:operator)}"
      end
    end

    # normalize operator value
    def normalize_value(value, remove_blank: false)
      remove_blank = true if !remove_blank.in?([true, false])
      # force type casting
      type_cast_record =
        case value
        when ActiveRecord::Base then value
        when Array              then value.find { |v| v.is_a?(ActiveRecord::Base) }
        end
      if type_cast_record
        raise ArgumentError, "value must be type casted: #{operator} => #{value.inspect}"
      end
      # select primary column for subquery
      if value.is_a?(ActiveRecord::Relation)
        # check for valid subquery operator [in, not_in]
        if !operator.in?(%i[ in not_in ])
          raise ArgumentError, "operator [#{operator}] does not accept subqueries"
        end
        # override invalid selects and select id
        projections = value.arel.projections
        projections.size == 1 && projections.first.name != "*" ? value : value.except(:select).select(:id)
      # operator specific
      else
        case operator
        when *%i[ in not_in ]
          value = value.split(",") if value.is_a?(String)
          # skip empty arrays if ignoring blank values
          remove_blank ? Array(value).select(&:present?).presence : Array(value)
        when *%i[ matches does_not_match ]
          if value.blank?
            nil # always ignore blank value
          else
            # accept ^ and $ for start and end of match
            value =~ /\A%|%\z/ ? value : "%#{value}%".remove(/\A%\^|\$%\z/)
          end
        else
          remove_blank && !value.in?([true, false]) ? value.presence : value
        end
      end
    end
  end
end
