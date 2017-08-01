module ActiveRecordSeek::Extension
  # seek usage: seed(column_operator => value, "association.column_operator" => value)
  def seek(seek_params = {}, global_options = {})
    query = all
    seeks = {}.with_indifferent_access
    seek_params = seek_params.with_indifferent_access
    # global options
    global_options = global_options.with_indifferent_access.assert_valid_keys(*%w[ namespace defaults remove_blank rescue_callback ])
    global_namespace = global_options[:namespace].to_s.presence
    seek_defaults = (global_options[:defaults] || {}).with_indifferent_access
    global_options[:remove_blank] = false if !global_options[:remove_blank].in?([true, false])
    # modify seek hashes
    [seek_params, seek_defaults].each do |seek_hash|
      # standardize keys
      seek_hash.transform_keys! do |original_namespace|
        # whitelist namespace
        original_namespace = original_namespace.remove(/[^A-Z0-9a-z_.]/)
        # auto prepend table_name if no namespace provided
        original_namespace = "#{table_name}.#{original_namespace}" if !original_namespace.include?(".")
        original_namespace
      end
      # optional removal of blank values
      if global_options[:remove_blank]
        # Array handled later after adjustment
        seek_hash.delete_if do |original_namespace, original_value|
          original_value.nil? || (original_value.is_a?(String) && original_value.blank?)
        end
      end
    end
    # append seek_defaults to seek_params
    seek_defaults.each do |original_namespace, original_value|
      seek_params[original_namespace] ||= original_value
    end
    # build seeks from format: without_unscoped_association.column_operator => original_value
    seek_params.each do |original_namespace, original_value|
      begin
        namespace, column_and_operator = original_namespace.split(".")
        association = namespace.dup
        debug_details = "#{global_namespace || :seek}: #{original_namespace} => #{original_value}".inspect
        # parse options [isolate, without]
        option_regex = /\Awithout_/
        option_without = association =~ option_regex ? true : false
        association.remove!(option_regex)
        option_regex = /\Aunscoped_/
        option_isolate = association =~ option_regex ? true : false
        association.remove!(option_regex)
        # parse column and operator
        matched_operator = ActiveRecordSeek::Operator.find_by_match(column_and_operator)
        operator, column = matched_operator.operator, matched_operator.parse(column_and_operator) if matched_operator
        # parse value
        requires_type_casting = original_value.is_a?(ActiveRecord::Base)
        requires_type_casting ||= original_value.is_a?(Array) && original_value.find { |v| v.is_a?(ActiveRecord::Base) }
        raise ArgumentError, "seek values must be type casted" if requires_type_casting
        value = matched_operator.normalize_value(original_value, remove_blank: global_options[:remove_blank])
        next if value.nil? && global_options[:remove_blank]
        # build seek scope
        seeks[namespace] ||= { association: association, isolate: option_isolate, without: option_without, queries: [] }
        seek_namespace = seeks[namespace]
        store_seek = -> (new_seek_query) do
          if !new_seek_query.is_a?(ActiveRecord::Relation)
            raise ArgumentError, "expected #{new_seek_query.inspect} to be a query scope: #{debug_details}"
          end
          (seek_namespace[:isolate] ? seek_namespace[:queries] : seek_namespace[:queries].clear) << new_seek_query
        end
        seek_model =
          if association == table_name
            unscoped.klass
          else
            reflection = reflect_on_association(association)
            if !reflection
              raise ArgumentError, "seek could not find reflection for #{association.inspect} association - #{original_namespace} => #{original_value}"
            end
            reflection.klass
          end
        seek_query = seek_namespace[:isolate] ? seek_model.unscoped : (seek_namespace[:queries].first || seek_model.unscoped)
        original_namespace_slug = original_namespace.scan(/[A-Za-z0-9]+/).join("_").underscore
        # order by columns on model only otherwise ignore
        if operator.in?(%w[ order reorder ])
          if seek_query.table_name == query.table_name && seek_query.respond_to?("#{operator}_#{column}")
            next store_seek.call(seek_query.send("#{operator}_#{column}", value))
          else
            Rails.env.production? ? next : raise(ArgumentError, "invalid sort: #{debug_details}")
          end
        # custom seek scope on query
        elsif query.respond_to?("seek_#{original_namespace_slug}")
          next store_seek.call(query.send("seek_#{original_namespace_slug}", value))
        # custom namespace scope
        elsif global_namespace && seek_query.respond_to?("#{global_namespace}_#{column_and_operator}")
          next store_seek.call(seek_query.send("#{global_namespace}_#{column_and_operator}", value))
        # custom seek scope
        elsif seek_query.respond_to?("seek_#{column_and_operator}")
          next store_seek.call(seek_query.send("seek_#{column_and_operator}", value))
        # auto seek
        elsif seek_query.respond_to?("where_#{column}")
          if operator.blank?
            raise ArgumentError, "no operator provided: #{debug_details}"
          end
          next store_seek.call(seek_query.send("where_#{column}", operator => value))
        end
        raise ArgumentError, "unknown #{debug_details}"
      rescue StandardError => error
        if global_options[:rescue_callback]
          global_options[:rescue_callback].call(
            error: error,
            global_options: global_options,
            seek_params: seek_params,
            debug_details: debug_details,
          )
        else
          raise error
        end
      end
    end
    # perform seeks on query
    seeks.each do |namespace, seek_options|
      association = seek_options[:association]
      seek_queries = seek_options.delete(:queries)
      seek_operator = seek_options[:without] ? :not_in : :in
      seek_queries.each do |seek_query|
        # non-association seek
        if seek_query.table_name == query.table_name
          # IN: merge where scope into current query / NOT IN: perform NOT IN self query
          query = seek_operator == :in ? query.where_merge(seek_query) : where_id(seek_operator => seek_query)
        # custom association seek
        elsif respond_to?("seek_#{association}")
          query = query.send("seek_#{association}", seek_operator, seek_query)
        # association seek
        else
          query = query.merge_association_query(association, seek_query, operator: seek_operator)
        end
      end
    end
    # result
    query
  end
end
