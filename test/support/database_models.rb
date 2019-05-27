require "support/database_helper"
require "support/database_schema"

class Member < ActiveRecord::Base
  has_many :member_groups
  has_many :groups, through: :member_groups
  has_many :group_categories, -> { distinct }, through: :groups, source: :category
  build_seek_scopes_for_all_columns
end

class MemberGroup < ActiveRecord::Base
  belongs_to :member
  belongs_to :group
  has_one :category, through: :group
  build_seek_scopes_for_all_columns
end

class Group < ActiveRecord::Base
  has_many :member_groups
  has_many :members, through: :member_groups
  belongs_to :category, class_name: "GroupCategory"
  build_seek_scopes_for_all_columns
end

class GroupCategory < ActiveRecord::Base
  has_many :groups
  build_seek_scopes_for_all_columns
end

class GroupProperty < ActiveRecord::Base
  belongs_to :group
  has_many :members, through: :group
  has_one  :category, through: :group
  build_seek_scopes_for_all_columns
end

FactoryBot.define do
  sequence(:uniq_i) { |i| i }
  sequence(:uniq_s) { |i| "uniq_#{i}_s" }

  factory :member do
    full_name { FactoryBot.generate(:uniq_s) }
  end

  factory :member_group do
    member { FactoryBot.create(:member) }
    group { FactoryBot.create(:group) }
  end

  factory :group do
    name { FactoryBot.generate(:uniq_s) }
    description { nil }
    category { FactoryBot.create(:group_category) }
  end

  factory :group_category do
    category { FactoryBot.generate(:uniq_s) }
  end

  factory :group_property do
    group { FactoryBot.create(:group) }
  end
end

class ActiveRecordSeek::ModelTest < Minitest::Test
  def setup
    clear_database
  end
end
