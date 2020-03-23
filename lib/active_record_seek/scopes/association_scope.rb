module ActiveRecordSeek
  module Scopes
    class AssociationScope < BaseScope

      attr_accessor(*%w[ components base_query association ])

      class JumpPlan
        include Concerns::InstanceVariableConcern

        attr_accessor(*%w[ reflection ])
        delegate(:each, to: :jumps)

        def after_initialize
          add_reflection_jump(reflection)
        end

        def jumps
          @jumps ||= []
        end

        def add_jump(model, association)
          jumps.push(Jump.new(model: model, association: association))
        end

        def add_reflection_jump(jump_reflection)
          # used to protect against infinite loop
          association = jump_reflection.source_reflection.name
          through_ref = jump_reflection.through_reflection
          if through_ref
            throughception = through_ref.klass.reflect_on_association(association)
            # check for throughception (jump through another association)
            # normal example:
            #   GroupProperty.has_many(:member_groups, through: :group)
            #   GroupProperty.has_many(:members, through: :member_groups)
            # throughception example:
            #   GroupProperty.has_many(:members, through: :group)
            if throughception && throughception.through_reflection
              add_reflection_jump(throughception) # add all throughception jumps
              add_reflection_jump(through_ref) # continue
            else
              add_jump(through_ref.klass, association)
              add_reflection_jump(through_ref)
            end
          else
            add_jump(jump_reflection.active_record, jump_reflection.name)
          end
        end
      end

      class Jump
        include Concerns::InstanceVariableConcern

        attr_accessor(*%w[ model association query ])

        def reflection
          model.reflect_on_association(association)
        end

        def primary_key
          reflection.macro == :belongs_to ? reflection.foreign_key : reflection.active_record_primary_key
        end

        def foreign_key
          reflection.macro == :belongs_to ? reflection.active_record_primary_key : reflection.foreign_key
        end

        def to_s
          "#{model}.where(#{primary_key} => #{query.model}.#{foreign_key})"
        end

        def apply
          model.unscoped.where(primary_key => query.to_active_record_query.select(foreign_key)).to_seek_query
        end
      end

      # Group => Member
      # jump through MemberGroup.group
      # jump base Member.member_groups
      # MemberGroup.where_group_id(in: Group.select_id)
      def apply
        association_reflection = base_query.model.reflect_on_association(association)
        if !association_reflection
          raise(
            ArgumentError,
            "#{base_query.model} does not have an association with the name: #{association.inspect}"
          )
        end
        association_query = association_reflection.klass.unscoped.to_seek_query
        association_query = association_query.apply(components).to_seek_query
        JumpPlan.new(reflection: association_reflection).each do |jump|
          association_query = jump.set(query: association_query).apply
        end
        association_query
      end

    end
  end
end
