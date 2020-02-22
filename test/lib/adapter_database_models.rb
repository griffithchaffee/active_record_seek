class Member < ActiveRecord::Base
  has_many :member_groups
  has_many :groups, through: :member_groups
  has_many :group_categories, -> { distinct }, through: :groups, source: :category
end

class MemberGroup < ActiveRecord::Base
  belongs_to :member
  belongs_to :group
  has_one :category, through: :group
end

class Group < ActiveRecord::Base
  has_many :member_groups
  has_many :members, through: :member_groups
  belongs_to :category, class_name: "GroupCategory"
end

class GroupCategory < ActiveRecord::Base
  has_many :groups
end

class GroupProperty < ActiveRecord::Base
  belongs_to :group
  has_many :members, through: :group
  has_one  :category, through: :group
end
