module ActiveRecordSeek
  module Scopes
    class SeekOrScope < BaseScope

      attr_accessor(*%w[ context_block ])

      def apply(query, *context_arguments, &context_block)
        context = Context.new(query.klass)
        context.instance_exec(*context_arguments, &context_block)
        # combine queries into single OR clause
        context.apply(query)
      end

      class Context
        attr_accessor(*%w[ klass queries ])

        def initialize(klass)
          self.klass   = klass
          self.queries = []
        end

        def add_query(&block)
          unscoped_query = klass.unscoped
          query = unscoped_query.instance_exec(unscoped_query, &block).to_seek_query
          queries.push(query) if query.has_where_sql?
          self
        end

        def apply(query)
          queries_sql = queries.map do |context_query|
            context_query.to_where_sql(enclose_with_parentheses: queries.size > 1)
          end.join(" OR ")
          query.where(queries_sql)
        end
      end

      module ActiveRecordScopeConcern

        extend ActiveSupport::Concern

        class_methods do
          def seek_or(*params, &block)
            SeekOrScope.new.apply(all, *params, &block)
          end
        end

      end


    end
  end
end
