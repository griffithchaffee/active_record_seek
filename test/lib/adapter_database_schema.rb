AdapterDatabase.instance.define_schema do
  create_table(:members) do |table|
    table.string(:name)
  end

  create_table(:member_groups) do |table|
    table.belongs_to(:member)
    table.belongs_to(:group)
  end

  create_table(:groups) do |table|
    table.string(:name, null: false)
    table.text(:description)
  end

  create_table(:group_categories) do |table|
    table.belongs_to(:group)

    table.string(:name)
  end

  create_table(:group_properties) do |table|
    table.belongs_to(:group)

    table.string(:value)
  end

  create_table(:projects) do |table|
    table.string(:name)
  end

  create_table(:members_projects) do |table|
    table.belongs_to(:member)
    table.belongs_to(:project)
  end
end
