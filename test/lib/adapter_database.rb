class AdapterDatabase
  def active_record
    ActiveRecord::Base
  end

  def adapter_namespace
    TestEnv.database_adapter_namespace
  end

  def configurations
    yaml_path = "#{File.dirname(__FILE__)}/adapter_database.yml"
    YAML.load_file(yaml_path)
  end

  def configuration
    configurations.fetch(adapter_namespace)
  end

  def connection
    active_record.connection
  end

  def establish_connection(new_configuration)
    active_record.establish_connection(new_configuration)
  end

  def adapter_name
    connection.adapter_name
  end

  def connect!
    establish_connection(configuration)
    self
  end

  def disconnect!
    if active_record.connected?
      active_record.connection.disconnect!
    end
    self
  end

  def drop_data!
    active_record.descendants.each do |model|
      model.delete_all if model.table_exists?
      model.reset_column_information
    end
    self
  end

  def drop_tables!
    connection.tables.each do |table_name|
      connection.drop_table(table_name)
    end
    self
  end

  def recreate_database!
    case adapter_namespace
    when "postgresql"
      establish_connection(configuration.merge("database" => "postgres"))
      connection.execute("DROP DATABASE IF EXISTS #{configuration.fetch("database")}")
      connection.execute("CREATE DATABASE #{configuration.fetch("database")}")
      establish_connection(configuration)
    when "mysql"
      establish_connection(configuration.merge("database" => ""))
      connection.execute("DROP DATABASE IF EXISTS #{configuration.fetch("database")}")
      connection.execute("CREATE DATABASE IF NOT EXISTS #{configuration.fetch("database")}")
      establish_connection(configuration)
    end
  end

  def define_schema(&block)
    @schema = block
    self
  end

  def write_schema!(&block)
    drop_tables!
    ActiveRecord::Schema.define(&@schema)
    self
  end

  class << self
    def instance
      @instance ||= new
    end
  end
end
