module ActiveRecordSeek
  module ScopeBuilderConcern
    extend ActiveSupport::Concern

    class_methods do
      # used to define seek scopes
      def build_seek_scopes(scope_builder_params = {})
        model = self
        scope_builder_params = scope_builder_params.with_indifferent_access
        ActiveRecordSeek::ColumnScopeBuilder.subclasses.each do |scope_builder_class|
          scope_builder = scope_builder_class.new(
            model,
            scope_builder_params[scope_builder.namespace]
          )
          scope_builder.build!
        end
      end
    end

  end
end
