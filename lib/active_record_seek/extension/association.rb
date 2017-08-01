module ActiveRecordSeek::Extension
  def to_where_sql
    reorder(nil).to_sql[/ WHERE (.*)/i, 1].presence
  end

  def where_merge(other_query)
    query = all
    # verify same table
    if query.klass != other_query.klass
      raise ArgumentError, "where_merge queries must be for same class: #{query.klass} != #{other_query.klass}"
    end
    # pull WHERE sql
    query.where(other_query.to_where_sql)
  end

  # merge association subquery into current query
  # acheived by building association jumps between association_query and current query
  # example: Member.merge_asssociation_query(:groups, Group.where_name(matches: "golf"))
  # example debug:
  # Group => Member
  # jump through MemberGroup.group
  # jump base Member.member_groups
  # MemberGroup.where_group_id(in: Group.select_id)
  # Member.where_id(in: MemberGroup.select_member_id)
  def merge_association_query(association, association_query, options = {})
    options = options.with_indifferent_access.reverse_merge(operator: :in, debug: false)
    # debug available for viewing jumps
    debug = -> (message) { puts message if options[:debug] }
    query = all
    association_reflection = query.reflect_on_association(association)
    raise ArgumentError, "unknown #{query.klass} association: #{association}" if !association_reflection
    debug.call("#{association_query.klass} => #{query.klass}")
    # final list of jumps containing model and association
    jumps = []
    add_jump = -> (klass, klass_association) { jumps.push(Struct.new(:model, :association).new(klass, klass_association)) }
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
          debug.call("jump throughception #{ref.active_record}.#{association}")
          jump_builder.call(throughception) # add all throughception jumps
          jump_builder.call(through_ref) # continue
        else
          debug.call("jump through #{through_ref.klass}.#{association}")
          add_jump.call(through_ref.klass, association)
          jump_builder.call(through_ref)
        end
      else
        debug.call("jump base #{ref.active_record}.#{ref.name}")
        add_jump.call(ref.active_record, ref.name)
      end
    end
    jump_builder.call(association_reflection)
    # build subqueries using jumps
    jumps.each_with_index do |jump, i|
      jump_ref = jump.model.reflect_on_association(jump.association)
      primary_key, foreign_key = jump_ref.active_record_primary_key, jump_ref.foreign_key
      # belongs_to means foreign key is actually the primary key
      primary_key, foreign_key = [foreign_key, primary_key] if jump_ref.macro == :belongs_to
      # use provided operator for final jump which allows for not_in queries
      operator = i + 1 == jumps.size ? options[:operator] : :in
      debug.call("#{jump.model}.where_#{primary_key}(#{operator}: #{association_query.klass}.select_#{foreign_key})")
      # must call model.unscoped to remove existing scope queries
      association_query = jump.model.unscoped.send("where_#{primary_key}", operator => association_query.send("select_#{foreign_key}"))
    end
    # merge result into query
    query.where_merge(association_query)
  end
end
