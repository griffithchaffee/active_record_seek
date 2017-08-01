initialize_database do
  create_table :members do |t|
    t.string :full_name
  end

  create_table :member_groups do |t|
    t.integer :member_id
    t.integer :group_id
  end

  create_table :groups do |t|
    t.string :name, null: false
    t.text :description
    t.integer :max_members
    t.integer :category_id
  end

  create_table :group_categories do |t|
    t.string :category
  end

  create_table :group_properties do |t|
    t.integer :group_id
    t.string :value
  end
end
