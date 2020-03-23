module ActiveRecordSeek
  class Component

    include Concerns::InstanceVariableConcern

    attr_accessor(*%w[
      base_query
      value
      operator
      column
      namespace
    ])
    attr_reader(*%w[ key association ])
    delegate(*%w[ active_record_query seek_query ], to: :base_query)
    delegate(*%w[ table_name adapter_name ], to: :seek_query)


    def key=(new_key)
      @key = new_key.to_s
      parts = @key.split(".").select(&:present?)
      self.operator    = parts.pop
      self.column      = parts.pop
      self.association = parts.pop || "self"
      self.namespace   = parts.pop || "default"
      @key
    end

    def association=(new_association)
      @association = new_association == "self" ? table_name : new_association
    end

    def is_base_query_component?
      association == table_name
    end

    def operator_class
      "::ActiveRecordSeek::Operators::#{operator.camelcase}Operator".constantize
    end

    def apply(query)
      operator_class.new(component: self).apply(query)
    end

  end
end
