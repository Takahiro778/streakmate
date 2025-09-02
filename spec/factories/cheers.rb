FactoryBot.define do
  factory :cheer do
    association :user
    association :log
  end
end
