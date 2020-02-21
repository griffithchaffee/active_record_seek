module ActiveRecordSeek
  module Collections
    class AssociationComponentCollection < BaseCollection

      attr_accessor(*%w[ namespace association components query association_query ])

      def debug(message)
        $debug ||= false
        puts(message) if $debug
      end
=begin
Member => Group
jump through MemberGroup.member
jump base Group.member_groups
MemberGroup.where_member_id(in: Member.select_id)
Group.where_id(in: MemberGroup.select_group_id)
SELECT "groups".* FROM "groups" WHERE (("groups"."id" IN (SELECT "member_groups"."group_id" FROM "member_groups" WHERE ("member_groups"."member_id" IN (SELECT "members"."id" FROM "members" WHERE ("members"."id" = 1))))))

Member => Group
jump through MemberGroup.member
jump base Group.member_groups
MemberGroup.where(member_id => Member.select(:id))
Group.where(id => MemberGroup.select(:group_id))
=end
      # merge association subquery into current query
      # acheived by building association jumps between association_query and current query
      # example: Member.merge_asssociation_query(:groups, Group.where_name(matches: "golf"))
      # example debug:
      # Group => Member
      # jump through MemberGroup.group
      # jump base Member.member_groups
      # MemberGroup.where_group_id(in: Group.select_id)
      # Member.where_id(in: MemberGroup.select_member_id)
      def apply_association_query
        jump_query = association_query
        debug("#{jump_query.klass} => #{query.klass}")
        jumps(jump_query).each_with_index do |jump, i|
          jump_ref = jump.model.reflect_on_association(jump.association)
          primary_key, foreign_key = jump_ref.active_record_primary_key, jump_ref.foreign_key
          # belongs_to means foreign key is actually the primary key
          primary_key, foreign_key = [foreign_key, primary_key] if jump_ref.macro == :belongs_to
          debug("#{jump.model}.where(#{primary_key} => #{jump_query.klass}.select(:#{foreign_key}))")
          # must call model.unscoped to remove existing scope queries
          jump_query = jump.model.unscoped.where(primary_key => jump_query.send(:select, foreign_key))
        end
        jump_query
      end

      def jumps(jump_query)
        instance_variable_yield(:@jumps) { |value| return value }
        @jumps = []
        add_jump = -> (klass, association) do
          assoc_h = { model: klass, association: association }
          assoc_struct = Struct.new(*assoc_h.keys.map(&:to_sym)).new(*assoc_h.values)
          @jumps.push(assoc_struct)
        end
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
        @jumps
      end

      def apply_components(query)
        query = query.seek_or(self) do |this|
          this.components.group_by(&:namespace).each do |namespace, namespace_components|
            case namespace
            when "unscoped"
              namespace_components.each do |component|
                add_query { component.apply(self) }
              end
            else
              add_query do |namespace_query|
                namespace_components.each do |component|
                  namespace_query = component.apply(namespace_query)
                end
                namespace_query
              end
            end
          end
        end
        query
      end

      def apply(query)
        case association
        when query.table_name
          return apply_components(query)
        else
          association_query = query.reflect_on_association(association).klass.unscoped
          association_query = apply_components(association_query)
          set(query: query, association_query: association_query)
          query.where(apply_association_query.to_seek_query.to_where_sql(enclose_with_parentheses: false))
        end
      end

    end
  end
end
