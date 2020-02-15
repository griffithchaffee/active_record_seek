=begin
Student.seek_or(self) do |this|
  add_clause { where(...) }
  add_clause { where(...).where(...) }
end
=end
module ActiveRecordSeek
  module Scopes
    class SeekAssociationScope < BaseScope

      def apply(*params, &block)
        #context = Context.new(model)
        #context.instance_exec(*params, &block)
        # combine clauses into single OR clause
        query
      end

      class Context
        attr_accessor(*%w[ model clauses ])

        def initialize(model)
          self.model   = model
          self.clauses = []
        end

        def add_clause(&block)
          new_clause = model.unscoped.all
          raw_clause = new_clause.instance_exec(new_clause, &block)
          clause     = Clause.build(clause: raw_clause)
          clauses.push(clause) if clause.has_where_sql?
          self
        end
      end

    end
  end
end
