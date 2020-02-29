module ActiveRecordSeek
  module Scopes
    class SeekOrScope < BaseScope

      attr_accessor(*%w[ context_block ])

      def apply(query, *context_arguments, &context_block)
        query = query.to_seek_query
        context = Context.new(query.model)
        context.instance_exec(*context_arguments, &context_block)
        context.apply(query)
      end

      class Context
        attr_accessor(*%w[ model queries ])

        def initialize(model)
          self.model   = model
          self.queries = []
        end

        def add_query(&block)
          unscoped_query = model.unscoped
          query = unscoped_query.instance_exec(unscoped_query, &block).to_seek_query
          queries.push(query) if query.has_where_sql?
          self
        end

        # combine queries into single OR clause
        def apply(query)
          queries_sql = queries.map do |context_query|
            context_query.to_where_sql(enclose_with_parentheses: queries.size > 1)
          end.join(" OR ")
          query.to_active_record_query.where(queries_sql).to_seek_query
        end
      end

      module ActiveRecordScopeConcern

        extend ActiveSupport::Concern

        class_methods do
          def seek_or(*params, &block)
            SeekOrScope.new.apply(all, *params, &block).to_active_record_query
          end
        end

      end


    end
  end
end
