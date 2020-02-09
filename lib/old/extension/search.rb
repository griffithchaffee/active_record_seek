module ActiveRecordSeek::Extension
  # search calls seek and also handles sorting
  def search(search_params, search_defaults = {})
    search_params = search_params.with_indifferent_access
    search_defaults = search_defaults.with_indifferent_access
    sort_column, sort_direction = nil
    # support sorting params (Ex: sort=column&direction=desc)
    [search_defaults, search_params].each do |hash|
      new_sort_direction = hash.delete(:direction) || "asc_nulls_last"
      new_sort_column = hash.delete(:sort).to_s.split(".").last
      if new_sort_column
        sort_column, sort_direction = new_sort_column, new_sort_direction
      end
    end
    # seek
    query = seek(search_params, defaults: search_defaults, namespace: :search, remove_blank: true)
    # sorting
    if sort_column
      if query.respond_to?("reorder_by_#{sort_column}")
        query = query.send("reorder_by_#{sort_column}", sort_direction)
      else
        query = query.reorder_by(sort_column => sort_direction)
      end
    end
    query
  end
end
