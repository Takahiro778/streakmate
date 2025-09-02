# ユーザー
5.times do
  User.create!(
    nickname: Faker::Name.name,
    email: Faker::Internet.unique.email,
    password: "password"
  )
end

# 目標
User.find_each do |user|
  2.times do
    user.goals.create!(
      title: Faker::Lorem.sentence(word_count: 3),
      description: Faker::Lorem.paragraph
    )
  end
end

# ログ
Goal.find_each do |goal|
  3.times do
    goal.logs.create!(
      minutes: rand(10..120),
      note: Faker::Lorem.sentence
    )
  end
end

# フォロー
users = User.all
users.each do |user|
  others = users.where.not(id: user.id).sample(2)
  others.each { |other| user.follow(other) }
end
