module ActiveRecordSeek::Extension
  def seek_or(seek_params = {}, &block)
    raise ArgumentError, "seek_or expects a seek hash or block with an array of scopes" if !seek_params.is_a?(Hash)
    where_or_sql = []
    # simple helper for model column combinations
    seek_params.each do |column_and_operator, value|
      seek_where_sql = unscoped.seek(column_and_operator => value).to_where_sql
      where_or_sql << seek_where_sql if seek_where_sql.present?
    end
    # bind block to unscoped instance to prevent pollution of where statements
    if block
      block_queries = unscoped.instance_eval(&block)
      block_queries = [block_queries] if !block_queries.is_a?(Array)
      block_queries.compact.each do |block_query|
        block_query_where_sql = block_query.to_where_sql
        where_or_sql << "(#{block_query_where_sql})" if block_query_where_sql.present?
      end
    end
    # join where_or_sql with OR
    where(where_or_sql.join(" OR "))
  end
end
