module ActiveRecordSeek::Extension
  def build_seek_scopes_for_all_columns(*params)
    build_seek_universal_scopes
    build_seek_scopes_for_columns(column_names, *params)
  end

  def build_seek_scopes_for_columns(local_column_names, type_builder_options: {})
    local_column_names = Array(local_column_names).map(&:to_s)
    local_column_names.each do |column_name|
      build_seek_select_scope_for_column(column_name)
      build_seek_order_scope_for_column(column_name)
      build_seek_type_scopes_for_column(column_name, type_builder_options)
      build_seek_where_scope_for_column(column_name)
    end
  end

  def build_seek_universal_scopes
    scope :order_random, -> { order("RANDOM()") }
    scope :order_by, -> (columns_and_ordering) do
      query = all
      next query if columns_and_ordering.blank?
      # ordering using Arel Node utalizes node.reverse for handling reverse_order!
      columns_and_ordering.each do |column, ordering|
        next if !column.to_s.in?(column_names)
        # order by nulls first (IS NOT NULL) or last (IS NULL)
        if ordering =~ /first/i
          query = query.order(arel_table[column].not_eq(nil))
        elsif ordering =~ /last/i
          query = query.order(arel_table[column].eq(nil))
        end
        # order by column
        if ordering =~ /desc/i
          query = query.order(arel_table[column].desc)
        elsif ordering =~ /asc/i
          query = query.order(arel_table[column].asc)
        end
      end
      query
    end
    scope :reorder_by, -> (columns_and_ordering) do
      except(:order).order_by(columns_and_ordering)
    end
  end

  def build_seek_select_scope_for_column(column_name)
    scope "select_#{column_name}", -> { select(column_name) }
  end

  def build_seek_order_scope_for_column(column_name)
    column = columns.find { |local_column| local_column.name == column_name.to_s }
    # order_column(:asc/:desc, :first/:last)
    scope "order_#{column}", -> (direction = "asc", null_order = nil) do
      direction = direction.to_s =~ /desc/i ? :desc : :asc
      null_order = null_order.blank? || null_order.to_s !~ /first/i ? "LAST" : "FIRST"
      order(arel_table[column].send(direction).to_sql + " NULLS #{null_order}")
    end
    # reorder_column(:asc/:desc, :first/:last)
    scope "reorder_#{column}", -> (direction = "asc", null_order = nil) do
      direction = direction.to_s =~ /desc/i ? :desc : :asc
      null_order = null_order.blank? || null_order.to_s !~ /first/i ? "LAST" : "FIRST"
      reorder(arel_table[column].send(direction).to_sql + " NULLS #{null_order}")
    end
  end

  def build_seek_type_scopes_for_column(column_name, rescue_callback: nil)
    column = columns.find { |local_column| local_column.name == column_name.to_s }
    # date/datetime
    # - integer values parsed with Time.at
    # - string values parsed with .parse
    if column.type.in?(%i[ date datetime ])
      %i[ gteq lteq eq not_eq ].each do |operator|
        scope "seek_#{column.name}_#{operator}", -> (value) do
          begin
            if value =~ /\d+(\.\d+)?/
              value = Time.at(value.to_i)
            else
              value = column.type == :date ? Date.parse(value.to_param) : DateTime.parse(value.to_param)
            end
            send("where_#{column.name}", operator => value)
          rescue TypeError, ArgumentError => error
            debug_params = {
              column: column.name,
              operator: operator,
              value: value,
            }
            if rescue_callback
              rescue_callback.call(error, debug_params)
            else
              raise error
            end
          end
        end
      end
    end
  end

  def build_seek_where_scope_for_column(column_name)
    column = columns.find { |local_column| local_column.name == column_name.to_s }
    scope "where_#{column.name}", -> (params = {}) do
      break if params.blank?
      arel_column = arel_table[column.name]
      query = all
      params.each do |operator, value|
        matched_operator = ActiveRecordSeek::Operator.find_by_match!(operator)
        value = matched_operator.normalize_value(value)
        operator = matched_operator.operator
        if value.is_a?(ActiveRecord::Relation)
          # arel.to_sql does not substitute bind paramaters so a sql string is built manually
          value_placeholder = 1234567890
          where_sql = arel_column.send(operator, value_placeholder).to_sql
          where_sql.gsub!(/'?#{value_placeholder}'?/, value.to_sql)
          query = query.where(where_sql)
        else
          arel_sql = -> (column_operator, column_value) { arel_column.send(column_operator, column_value).to_sql }
          case operator.presence
          when *%i[ in not_in ]
            has_nil_value = nil.in?(value)
            value -= [nil]
            if column.null == false || (operator == :in && !has_nil_value)
              # IN value / NOT IN value
              query = query.where(arel_sql.call(operator, value))
            elsif (operator == :in && has_nil_value) || (operator == :not_in && !has_nil_value)
              # IN value OR IS NULL / NOT IN value AND IS NOT NULL
              query = query.seek_or("#{column.name}_eq" => nil) { where(arel_sql.call(operator, value)) }
            elsif operator == :not_in && has_nil_value
              # NOT IN value AND IS NOT NULL
              query = query.where(arel_sql.call(operator, value)).where(arel_sql.call(:not_eq, nil))
            else
              raise ArgumentError, "where_#{column.name}(#{operator} => #{value}) is unsupported"
            end
          when *%i[ ieq not_ieq ]
            operator = operator.to_s.gsub("ieq", "eq").to_sym
            if value.nil?
              query = query.where(arel_sql.call(operator, value))
            else
              query = query.where(arel_column.lower.send(operator, arel_table.lower(value)).to_sql)
            end
          when *%i[ lt gt lteq gteq ]
            raise ArgumentError, "nil value passed to #{operator}" if value.nil?
            query = query.where(arel_sql.call(operator, value))
          when *%i[ matches does_not_match ]
            if value.nil?
              query = query.where("1=0") if operator == :does_not_match
            else
              query = query.where(arel_sql.call(operator, value))
            end
          when nil
            raise ArgumentError, "no operator provided to where_#{column.name} query (value=#{value.inspect})"
          else
            query = query.where(arel_sql.call(operator, value))
          end
        end
      end
      query
    end
  end
end
