module TestEnv
  class << self
    def locked_gem?(gem_name)
      Bundler.locked_gems.dependencies.key?(gem_name)
    end

    def database_adapter_namespace
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
