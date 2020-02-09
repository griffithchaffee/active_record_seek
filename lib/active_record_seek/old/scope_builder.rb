module ActiveRecordSeek
  class ScopesBuilder
    attr_accessor(*%w[ model columns ])

    def initialize(model)
      self.model = model
      column_names ||= model.column_names
      self.columns = column_names.map do |column_name|
        column = model.columns.find { |column| column.name == column_name }
        raise(ArgumentError, "Unknown #{model} column: #{column_name}") if !column
        column
      end
    end

    def build_all_scopes!
      build_where_scopes!
    end

    def build_where_scopes!
      WhereScopeBuilder.new(builder: self)
    end

  end
end
