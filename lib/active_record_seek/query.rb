module ActiveRecordSeek
  class Query

    include Concerns::InstanceVariableConcern

    attr_reader(*%w[ query ])

    def query=(new_query)
      instance_variable_reset(:@where_sql)
      @query = new_query
    end

    def model
      query.klass
    end

    def arel_table
      query.arel_table
    end

    def arel_column(column_name)
      arel_table[column_name]
    end

    def to_where_sql(enclose_with_parentheses: true)
      if !instance_variable_defined?(:@where_sql)
        @where_sql = query.reorder(nil).to_sql.split(" WHERE ", 2)[1].to_s.strip
      end
      return "" if @where_sql.blank?
      enclose_with_parentheses ? "(#{@where_sql})" : @where_sql
    end

    def has_where_sql?
      to_where_sql.present?
    end

    def merge(other_query)
      query.where(other_query.to_where_sql)
    end

  end
end
