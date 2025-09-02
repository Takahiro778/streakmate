FactoryBot.define do
  factory :user do
    sequence(:nickname) { |n| "user#{n}" }
    sequence(:email)    { |n| "user#{n}@example.com" }
    password { "password1" } # 英数ミックス
  end
end
