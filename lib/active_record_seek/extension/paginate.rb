module ActiveRecordSeek::Extension
  # batching
  def find_each_in_order(*params, &block)
    find_in_ordered_batches(*params) do |batch|
      batch.each(&block)
    end
  end

  def find_in_ordered_batches(batch_size: 1000, offset: 0)
    raise ArgumentError, "batch_size must be greater than 0" if batch_size <= 0
    raise ArgumentError, "offset can not be negative" if offset < 0
    # fallback order by id because records must have a definite order
    query = all.order(id: :desc)
    loop do
      current_batch = query.offset(offset).limit(batch_size)
      current_batch_size = current_batch.size
      break if current_batch_size == 0
      yield current_batch
      offset += current_batch_size
    end
    offset
  end

  def paginate(*params, &block)
    Paginate.new(all).paginate(*params, &block)
  end

  class Paginate
    attr_reader(*%i[
      query records raw_count
      limit offset limit_min limit_max
      page pages next_page previous_page
    ])

    def initialize(query)
      # query must have a definite order
      @query = query.order(id: :desc)
    end

    def paginate(params = {}, defaults = {})
      permitted_keys = %i[ page limit limit_min limit_max ]
      internal_defaults = { page: 1, limit: 20, limit_min: 1, limit_max: 50 }
      defaults = defaults.reverse_merge(internal_defaults)
      params = params.select { |k,v| v.to_i.nonzero? }.reverse_merge(defaults)
      # initial values
      params.assert_valid_keys(*permitted_keys).each do |key, value|
        instance_variable_set("@#{key}", value)
      end
      @raw_count = @query.count(:id)
      # adjust limit
      @limit = @limit_min if @limit < @limit_min
      @limit = @limit_max if @limit > @limit_max
      # adjust pages
      @pages = (@raw_count.to_f / @limit).ceil.to_i
      @pages = 1 if @pages < 1
      # adjust page
      @page = 1 if @page < 1
      @page = @pages if @page > @pages
      # rest
      @next_page     = @page < @pages ? @page + 1 : @pages
      @previous_page = @page > 1 ? @page - 1 : 1
      @offset        = (@page - 1) * @limit
      @records       = Array(@query.offset(@offset).limit(@limit))
      self
    end

    def each_page(*params, &block)
      Array(1..pages).each(*params, &block)
    end

    def has_previous_page?
      page > 1
    end

    def has_next_page?
      page < pages
    end

    def method_missing(method, *params, &block)
      records.send(method, *params, &block)
    end
  end
end
