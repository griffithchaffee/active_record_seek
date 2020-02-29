FactoryBot.define do
  sequence(:uniq_i) { |i| i }
  sequence(:uniq_s) { |i| "uniq_#{i}_s" }

  factory(:member) do
    name { FactoryBot.generate(:uniq_s) }
  end

  factory(:member_group) do
    member { FactoryBot.create(:member) }
    group { FactoryBot.create(:group) }
  end

  factory(:group) do
    name { FactoryBot.generate(:uniq_s) }
    description { nil }
  end

  factory(:group_category) do
    group { FactoryBot.create(:group) }
    name { FactoryBot.generate(:uniq_s) }
  end

  factory(:project) do
    name { FactoryBot.generate(:uniq_s) }
  end
end
