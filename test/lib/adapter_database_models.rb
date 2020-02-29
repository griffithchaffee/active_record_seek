class Member < ActiveRecord::Base
  has_many :member_groups
  has_many :groups, through: :member_groups
  # has_many through source
  has_many :group_categories, -> { distinct }, through: :groups, source: :category
end

class MemberGroup < ActiveRecord::Base
  belongs_to :member
  belongs_to :group
  # has_one through tests
  has_one :category, through: :group
end

class Group < ActiveRecord::Base
  has_many :member_groups
  has_many :members, through: :member_groups
  has_one  :category, class_name: "GroupCategory"
end

class GroupCategory < ActiveRecord::Base
  belongs_to :group
  # has_many throughception
  has_many :members, through: :group
end

class Project < ActiveRecord::Base
  has_and_belongs_to_many :members
end
