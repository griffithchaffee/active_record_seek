module ActiveRecordSeek
  module Collections
    class AssociationComponentCollection < BaseCollection

      attr_accessor(*%w[ namespace association components query association_query ])

      def debug(message)
        $debug ||= false
        puts(message) if $debug
      end

      # Group => Member
      # jump through MemberGroup.group
      # jump base Member.member_groups
      # MemberGroup.where_group_id(in: Group.select_id)
      # Member.where_id(in: MemberGroup.select_member_id)
      def apply_association_query
        jump_query = association_query
        debug("#{jump_query.model} => #{query.model}")
        jumps(jump_query).each_with_index do |jump, i|
          jump_ref = jump.model.reflect_on_association(jump.association)
          primary_key, foreign_key = jump_ref.active_record_primary_key, jump_ref.foreign_key
          # belongs_to means foreign key is actually the primary key
          primary_key, foreign_key = [foreign_key, primary_key] if jump_ref.macro == :belongs_to
          debug("#{jump.model}.where(#{primary_key} => #{jump_query.model}.select(:#{foreign_key}))")
          # must call model.unscoped to remove existing scope queries
          jump_query = jump.model.unscoped.where(primary_key => jump_query.select(foreign_key))
        end
        jump_query
      end

      def jumps(jump_query)
        jumps = []
        add_jump = -> (model, association) do
          assoc_h = { model: model, association: association }
          assoc_struct = Struct.new(*assoc_h.keys.map(&:to_sym)).new(*assoc_h.values)
          jumps.push(assoc_struct)
        end
        # recursive jump builder
        jump_builder = -> (ref) do
          # used to protect against infinite loop
          association = ref.source_reflection.name
          through_ref = ref.through_reflection
          if through_ref
            throughception = through_ref.klass.reflect_on_association(association)
            # check for throughception (jump through another association)
            # normal example:
            #   GroupProperty.has_many(:member_groups, through: :group)
            #   GroupProperty.has_many(:members, through: :member_groups)
            # throughception example:
            #   GroupProperty.has_many(:members, through: :group)
            if throughception && throughception.through_reflection
              debug("jump throughception #{ref.active_record}.#{association}")
              jump_builder.call(throughception) # add all throughception jumps
              jump_builder.call(through_ref) # continue
            else
              debug("jump through #{through_ref.klass}.#{association}")
              add_jump.call(through_ref.klass, association)
              jump_builder.call(through_ref)
            end
          else
            debug("jump base #{ref.active_record}.#{ref.name}")
            add_jump.call(ref.active_record, ref.name)
          end
        end
        jump_builder.call(query.reflect_on_association(association))
        jumps
      end

      def apply(query)
        case association
        when query.table_name
          return query.apply(components)
        else
          reflection = query.reflect_on_association(association)
          if !reflection
            raise(
              ArgumentError,
              "#{query.model} does not have an association with the name: #{association.inspect}"
            )
          end
          association_query = reflection.klass.unscoped.to_seek_query
          association_query = association_query.apply(components)
          set(query: query, association_query: association_query)
          query.merge_where_sql(apply_association_query)
        end
      end

    end
  end
end
