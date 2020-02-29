module ActiveRecordSeek
  class Query

    include Concerns::InstanceVariableConcern

    delegate(*%w[ seek_or seek where reflect_on_association ], to: :active_record_query)
    attr_reader(*%w[ active_record_query ])

    def active_record_query=(new_query)
      instance_variable_reset(:@where_sql)
      @active_record_query = new_query
    end

    def to_seek_query
      self
    end

    def model
      active_record_query.klass
    end

    def arel_table
      active_record_query.arel_table
    end

    def table_name
      model.table_name
    end

    def arel_column(column_name)
      arel_table[column_name]
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

    def merge(other_query)
      active_record_query.where(other_query.to_seek_query.to_where_sql(enclose_with_parentheses: false)).to_seek_query
    end

  end
end
