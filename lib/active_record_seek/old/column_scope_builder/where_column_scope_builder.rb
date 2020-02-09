module ActiveRecordSeek
  class WhereColumnScopeBuilder < ColumnScopeBuilder
    def build!
      add_model_scope("seek_#{column.name}") do |operators|
        query = self
        operators.map do |operator_type, operator_value|
          send("

        end
      end
    end
  end
end
