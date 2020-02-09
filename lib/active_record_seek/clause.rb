module ActiveRecordSeek
  class Clause

    include Concerns::BuildConcern
    include Concerns::InstanceVariableConcern

    attr_reader(*%w[ clause ])

    def clause=(new_clause)
      instance_variable_reset(:@where_sql)
      @clause = new_clause
    end

    def to_where_sql(enclose_with_parentheses: true)
      # build @where_sql
      if !instance_variable_defined?(:@where_sql)
        @where_sql = clause.reorder(nil).to_sql.split(" WHERE ", 2)[1].to_s.strip
      end
      return nil if @where_sql.blank?
      enclose_with_parentheses ? "(#{@where_sql})" : @where_sql
    end

    def has_where_sql?
      !to_where_sql.nil?
    end

  end
end
