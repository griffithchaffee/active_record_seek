AdapterDatabase.instance.define_schema do
  create_table :members do |t|
    t.string :name
  end

  create_table :member_groups do |t|
    t.belongs_to :member
    t.belongs_to :group
  end

  create_table :groups do |t|
    t.belongs_to :category

    t.string :name, null: false
    t.text :description
  end

  create_table :group_categories do |t|
    t.string :category
  end

  create_table :group_properties do |t|
    t.belongs_to :group

    t.string :value
  end
end
