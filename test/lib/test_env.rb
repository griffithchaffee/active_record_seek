module TestEnv
  class << self
    def locked_gem?(gem_name)
      Bundler.locked_gems.dependencies.key?(gem_name)
    end

    def database_adapter_namespace
      if ENV["TEST_DB_ADAPTER"].present?
        raise(RunetimeError, "Unknown TEST_DB_ADAPTER: '#{ENV["TEST_DB_ADAPTER"]}'") if !["postgresql", "mysql", "sqlite"].include?(ENV["TEST_DB_ADAPTER"])
        return ENV["TEST_DB_ADAPTER"]
      end
      if locked_gem?("pg")
        "postgresql"
      elsif locked_gem?("mysql2")
        "mysql"
      elsif locked_gem?("sqlite3")
        "sqlite"
      else
        raise(RunetimeError, "Undefined database adapter gem")
      end
    end
  end
end
