module ActiveRecordSeek
  class Component

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

    def operator_class
      "::ActiveRecordSeek::Operators::#{operator.camelcase}Operator".constantize
    end

    def predicate
      Predicate.new(component: self)
    end

    def apply(query)
      predicate.apply(query)
    end

  end
end
