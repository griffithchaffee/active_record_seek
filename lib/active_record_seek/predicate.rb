module ActiveRecordSeek
  class Predicate

    include Concerns::InstanceVariableConcern

    attr_accessor(*%w[ component query ])
    attr_writer(*%w[ arel_table arel_column arel_value ])

    def arel_table
      instance_variable_yield(:@arel_table) { |value| return value }
      query.arel_table
    end

    def arel_column
      instance_variable_yield(:@arel_column) { |value| return value }
      arel_table[component.column]
    end

    def arel_value
      instance_variable_yield(:@arel_value) { |value| return value }
      component.value
    end

    def apply(query)
      set(query: query)
      component.operator_class.new(predicate: self).apply
    end

  end
end
