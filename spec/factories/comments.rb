FactoryBot.define do
  factory :comment do
    association :user
    association :log
    body { "Great job!" }
  end
end
