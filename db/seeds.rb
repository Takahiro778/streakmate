# --- 本番では実行しない ---
if Rails.env.production?
  puts "[seeds] Skip on production"
  return
end

require "faker"
Faker::Config.locale = :ja

# ---------------- ヘルパ ----------------

def set_if_column!(model_class, attrs, name, value)
  attrs[name] = value if model_class.column_names.include?(name.to_s)
end

def first_existing_column(model_class, candidates)
  candidates.find { |n| model_class.column_names.include?(n) }
end

def set_any_text_field!(model_class, attrs, candidates, value)
  col = first_existing_column(model_class, candidates)
  attrs[col.to_sym] = value if col
end

# enum / ActiveHash / string / integer のいずれでも安全にセット
def set_enum_or_activehash!(model_class, attrs, name, fallback: "public")
  name_s = name.to_s

  # 1) ActiveRecord enum（キー名で入れる）
  if model_class.respond_to?(:defined_enums) && model_class.defined_enums.key?(name_s)
    attrs[name] = model_class.defined_enums[name_s].keys.first
    return true
  end

  # 2) ActiveHash（*_id があり、関連クラスから実在IDを拾う）
  id_col = "#{name_s}_id"
  if model_class.column_names.include?(id_col)
    assoc_klass = model_class.reflect_on_association(name)&.klass rescue nil
    first_id = assoc_klass&.all&.first&.id rescue nil
    attrs[id_col.to_sym] = first_id || 1
    return true
  end

  # 3) string カラムなら既定値
  if (col = model_class.columns_hash[name_s]) && col.type == :string
    attrs[name] = fallback
    return true
  end

  # 4) integer カラムなら 0
  if (col = model_class.columns_hash[name_s]) && [:integer, :bigint].include?(col.type)
    attrs[name] = 0
    return true
  end

  false
end

# Log.minutes の inclusion を読んで許容セットから選ぶ
def allowed_minutes_choices
  return [10, 15, 20, 25, 30, 45, 60, 75, 90, 120] unless defined?(Log)
  inclusion = Log.validators_on(:minutes).find { |v| v.is_a?(ActiveModel::Validations::InclusionValidator) }
  set = inclusion&.options&.dig(:in)
  set.respond_to?(:to_a) ? set.to_a : [10, 15, 20, 25, 30, 45, 60, 75, 90, 120]
end

def random_past_datetime
  rand(0..14).days.ago.change(hour: [6, 12, 20].sample)
end

# ---------------- ここから投入 ----------------

ActiveRecord::Base.transaction do
  puts "[seeds] wipe tables..."
  Log.delete_all            if defined?(Log)
  Goal.delete_all           if defined?(Goal)
  Follow.delete_all         if defined?(Follow)
  Relationship.delete_all   if defined?(Relationship)
  User.delete_all           if defined?(User)

  puts "[seeds] create users..."
  fixed_users = [
    { nickname: "筋トレ好き太郎",   email: "taro@example.com" },
    { nickname: "夜更かしエンジニア", email: "dev@example.com" },
    { nickname: "朝活サラリーマン",   email: "asa@example.com" },
    { nickname: "本好き女子",       email: "book@example.com" },
    { nickname: "旅人ケンタ",       email: "kenta@example.com" }
  ]

  # 固定5名 + ランダム5名（合計10人）
  users = []
  fixed_users.each_with_index do |u, i|
    users << User.create!(
      nickname: u[:nickname],
      email:    u[:email],
      password: "pass1234#{i}"
    )
  end
  5.times do |i|
    users << User.create!(
      nickname: Faker::Name.name,
      email:    Faker::Internet.unique.email,
      password: "pass1234#{i + 5}"
    )
  end

  puts "[seeds] create follows..."
  users.each do |u|
    (users - [u]).sample(3).each do |v|
      if u.respond_to?(:follow)
        begin
          u.follow(v)
          next
        rescue StandardError
        end
      end

      if defined?(Follow) && Follow.column_names.include?("follower_id") && Follow.column_names.include?("followed_id")
        begin
          Follow.create!(follower_id: u.id, followed_id: v.id)
          next
        rescue StandardError
        end
      end

      if defined?(Relationship) && Relationship.column_names.include?("follower_id") && Relationship.column_names.include?("followed_id")
        begin
          Relationship.create!(follower_id: u.id, followed_id: v.id)
          next
        rescue StandardError
        end
      end
    end
  end

  puts "[seeds] create goals & logs..."
  # 見栄え用カテゴリ候補（文字列カラムのときのみ使用）
  label_categories = %w[運動 学習 健康 クリエイティブ]

  users.each do |u|
    2.times do
      # ------ Goal ------
      title_word = label_categories.sample
      goal_attrs = {
        title:       "#{title_word}のゴール",
        description: Faker::Lorem.paragraph_by_chars(number: 120)
      }
      set_if_column!(Goal, goal_attrs, :success_criteria, "2週間継続できたらOK")
      # enum / ActiveHash / string それぞれに対応
      set_enum_or_activehash!(Goal, goal_attrs, :category,   fallback: title_word)
      set_enum_or_activehash!(Goal, goal_attrs, :visibility, fallback: "public")

      goal = u.goals.create!(goal_attrs)

      # ------ Logs（直近2週間の見栄え用データ）------
      7.times do
        log_attrs = { created_at: random_past_datetime }

        # minutes / duration / spent_minutes / length のどれかを埋める
        mins_col = first_existing_column(Log, %w[minutes duration spent_minutes length])
        log_attrs[mins_col.to_sym] = allowed_minutes_choices.sample if mins_col

        # テキスト（存在するテキスト列だけに入れる）
        samples = case title_word
                  when "運動"       then ["ランニング 3km", "ジムで筋トレ", "ストレッチ20分"]
                  when "学習"       then ["Rails環境構築", "RSpecの章を読んだ", "教材1章クリア"]
                  when "健康"       then ["23:30就寝", "7:00起床", "水を2L飲んだ"]
                  when "クリエイティブ" then ["記事を下書き", "サムネ作成", "構成メモ"]
                  else                    [Faker::Lorem.sentence]
                  end
        set_any_text_field!(Log, log_attrs, %w[note memo content body description message text], samples.sample)

        # Log 側の visibility / category も（あれば）設定
        set_enum_or_activehash!(Log, log_attrs, :visibility, fallback: "public")
        set_enum_or_activehash!(Log, log_attrs, :category,   fallback: title_word)

        # 関連（belongs_to）に合わせて外部キー付与
        log_attrs[:goal_id] = goal.id if Log.reflect_on_association(:goal)&.macro == :belongs_to
        log_attrs[:user_id] = u.id    if Log.reflect_on_association(:user)&.macro == :belongs_to

        if u.respond_to?(:logs) && u.logs.is_a?(ActiveRecord::Associations::CollectionProxy)
          u.logs.create!(log_attrs.except(:user_id))
        else
          Log.create!(log_attrs)
        end
      end
    end
  end
end

puts "[seeds] Done."
puts "Users: #{defined?(User) ? User.count : 0}, Goals: #{defined?(Goal) ? Goal.count : 0}, Logs: #{defined?(Log) ? Log.count : 0}"
