FactoryBot.define do
  factory :goal do
    association :user
    title { "Read 30min" }
    description { "Daily reading" }
    success_criteria { "7 days streak" }
    category_id { 1 }         # ← ActiveHash を使う前提
    visibility { :public }    # ← Goal に visibility enum があるならそのまま
  end
end
