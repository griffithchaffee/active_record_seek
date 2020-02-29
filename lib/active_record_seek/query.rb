module ActiveRecordSeek
  class Query

    include Concerns::InstanceVariableConcern

    delegate(*%w[ table_name arel_table reflect_on_association ], to: :model)
    attr_reader(*%w[ active_record_query ])

    def active_record_query=(new_active_record_query)
      instance_variable_reset(:@where_sql)
      @active_record_query = new_active_record_query
    end
    alias_method(:to_active_record_query, :active_record_query)

    def to_seek_query
      self
    end

    def model
      to_active_record_query.klass
    end

    def adapter_name
      model.connection.adapter_name
    end

    def arel_column(column_name)
      arel_table[column_name]
    end

    def merge_where_sql(other_query)
      to_active_record_query.where(other_query.to_seek_query.to_where_sql(enclose_with_parentheses: false))
    end

    def to_where_sql(enclose_with_parentheses: true)
      if !instance_variable_defined?(:@where_sql)
        @where_sql = active_record_query.reorder(nil).to_sql.split(" WHERE ", 2)[1].to_s.strip
      end
      return "" if @where_sql.blank?
      enclose_with_parentheses ? "(#{@where_sql})" : @where_sql
    end

    def has_where_sql?
      to_where_sql.present?
    end

    def apply(components)
      to_active_record_query.seek_or(self) do |this|
        components.group_by(&:namespace).each do |namespace, namespace_components|
          case namespace
          when "unscoped"
            namespace_components.each do |component|
              add_query { component.apply(self) }
            end
          else
            add_query do |namespace_query|
              namespace_components.each do |component|
                namespace_query = component.apply(namespace_query)
              end
              namespace_query
            end
          end
        end
      end
    end

  end
end
