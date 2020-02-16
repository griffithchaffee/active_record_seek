class MemoryDatabase
  def connect!
    ActiveRecord::Base.establish_connection(adapter: "sqlite3", database: ":memory:")
    self
  end

  def disconnect!
    if ActiveRecord::Base.connected?
      ActiveRecord::Base.connection.disconnect!
    end
    self
  end

  def reset!
    ActiveRecord::Base.descendants.each do |model|
      model.delete_all if model.table_exists?
      model.reset_column_information
    end
    self
  end

  def define_schema!(&block)
    # reconnect drops/creates database
    disconnect!
    connect!
    ActiveRecord::Schema.define(&block)
    self
  end

  class << self
    def instance
      @instance ||= new
    end
  end
end
