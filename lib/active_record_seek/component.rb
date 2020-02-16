module ActiveRecordSeek
  class Component

    include Concerns::InstanceVariableConcern

    attr_accessor(*%w[ value query_association ])
    attr_reader(*%w[ key namespace association column operator query_association ])

    def key=(new_key)
      @key = new_key.to_s
      parts = @key.split(".")
      @operator    = parts.pop
      @column      = parts.pop
      @association = parts.pop || "self"
      @namespace   = parts.pop || "default"
      @key
    end

    def query=(new_query)
      # convert association for query
      self.query_association =
        case association
        when "self" then new_query.table_name
        else association
        end
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
