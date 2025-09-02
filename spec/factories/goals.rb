FactoryBot.define do
  factory :goal do
    association :user
    title { "Read 30min" }
    description { "Daily reading" }
    success_criteria { "7 days streak" }
    category { Goal.categories.keys.first } # or :study
    visibility { :public }
  end
end
