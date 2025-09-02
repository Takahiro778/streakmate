FactoryBot.define do
  factory :log do
    association :user
    minutes { 30 }
    category { :study }
    visibility { :public }
    memo { nil }
  end
end
