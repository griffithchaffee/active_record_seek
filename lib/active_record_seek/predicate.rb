module ActiveRecordSeek
  class Predicate

    include Concerns::BuildConcern
    include Concerns::InstanceVariableConcern

    attr_accessor(*%w[ value clause ])
    attr_reader(*%w[ key namespace association column operator ])

    def key=(new_key)
      @key = new_key.to_s
      parts = @key.split(".")
      @operator    = parts.pop
      @column      = parts.pop
      @association = parts.pop || "self"
      @namespace   = parts.pop || "default"
      @key
    end

    def arel_table
      clause.arel_table
    end

    def arel_column
      arel_table[column]
    end

    def operator_class
      "::ActiveRecordSeek::Operators::#{operator.camelcase}Operator".constantize
    end

    def apply(clause)
      set(clause: clause)
      seek_operator = operator_class.build(predicate: self)
      seek_operator.apply
    end

  end
end
