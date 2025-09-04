FactoryBot.define do
  factory :goal_task do
    goal { nil }
    title { "MyString" }
    estimated_minutes { 1 }
    position { 1 }
    due_on { "2025-09-04" }
    completed_at { "2025-09-04 18:29:29" }
  end
end
