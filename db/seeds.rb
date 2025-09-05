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

  if model_class.respond_to?(:defined_enums) && model_class.defined_enums.key?(name_s)
    # enum は先頭キー（例: "public"）を入れる
    attrs[name] = model_class.defined_enums[name_s].keys.first
    return true
  end

  id_col = "#{name_s}_id"
  if model_class.column_names.include?(id_col)
    assoc_klass = model_class.reflect_on_association(name)&.klass rescue nil
    first_id = assoc_klass&.all&.first&.id rescue nil
    attrs[id_col.to_sym] = first_id || 1
    return true
  end

  if (col = model_class.columns_hash[name_s]) && col.type == :string
    attrs[name] = fallback
    return true
  end

  if (col = model_class.columns_hash[name_s]) && [:integer, :bigint].include?(col.type)
    attrs[name] = 0
    return true
  end

  false
end

def allowed_minutes_choices
  return [15, 30, 45, 60] unless defined?(Log)
  inclusion = Log.validators_on(:minutes).find { |v| v.is_a?(ActiveModel::Validations::InclusionValidator) }
  set = inclusion&.options&.dig(:in)
  set.respond_to?(:to_a) ? set.to_a : [15, 30, 45, 60]
end

def random_past_datetime
  (rand(0..14)).days.ago.change(hour: [6, 12, 20].sample)
end

# ---------------- 日本語テンプレ ----------------

CATEGORIES = {
  "運動" => {
    goal_titles: ["運動のゴール", "体力づくりのゴール"],
    descriptions: [
      "週に3回、無理のないペースで運動を継続する。ランニングや筋トレ、ストレッチを組み合わせて習慣化する。",
      "朝か夜のどちらかで軽い有酸素運動を取り入れ、日々の疲れをためにくくする。"
    ],
    criteria: [
      "1か月で12回以上の運動を達成する",
      "2週間連続で週3回の運動を継続する"
    ],
    log_samples: ["ランニング 3km", "自重トレーニング 20分", "ストレッチ 15分"]
  },
  "学習" => {
    goal_titles: ["学習のゴール", "プログラミング学習のゴール"],
    descriptions: [
      "毎日30分以上の学習を続け、基礎を固める。教材の写経や小さなアプリ作成で手を動かす。",
      "復習とアウトプットをセットにして、理解を深める。"
    ],
    criteria: [
      "Railsチュートリアルを最後まで完了する",
      "毎日30分×2週間の学習を継続する"
    ],
    log_samples: ["教材1章を進めた", "Rails 環境構築", "RSpecの章を読んだ"]
  },
  "健康" => {
    goal_titles: ["健康のゴール", "生活リズムのゴール"],
    descriptions: [
      "就寝・起床の時刻を整え、1日のパフォーマンスを高める。水分補給や軽い運動も意識する。",
      "だらだらスマホ時間を減らし、眠る前のリラックスタイムをつくる。"
    ],
    criteria: [
      "23:30までに就寝を1週間継続",
      "1日に水2Lを1週間継続"
    ],
    log_samples: ["23:30 就寝", "7:00 起床", "水を2L飲んだ"]
  },
  "クリエイティブ" => {
    goal_titles: ["クリエイティブのゴール", "制作のゴール"],
    descriptions: [
      "毎日短時間でも制作に手をつける。ラフでもよいのでアウトプットを残す。",
      "完成度より継続を重視し、アイデアを形にする。"
    ],
    criteria: [
      "記事を3本下書きする",
      "サムネを5案作る"
    ],
    log_samples: ["記事の構成メモ", "サムネ画像の草案", "下書きを1本追加"]
  }
}.freeze

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

  users = []
  fixed_users.each_with_index do |u, i|
    users << User.create!(nickname: u[:nickname], email: u[:email], password: "pass1234#{i}")
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
      begin
        if u.respond_to?(:follow)
          u.follow(v)
        elsif defined?(Follow)
          Follow.create!(follower_id: u.id, followed_id: v.id)
        elsif defined?(Relationship)
          Relationship.create!(follower_id: u.id, followed_id: v.id)
        end
      rescue StandardError
        # 既存の一意制約に引っかかったらスキップ
      end
    end
  end

  puts "[seeds] create goals & logs..."
  users.each do |u|
    2.times do
      label = CATEGORIES.keys.sample
      conf  = CATEGORIES[label]

      # ------ Goal ------
      title       = conf[:goal_titles].sample
      description = conf[:descriptions].sample
      criteria    = conf[:criteria].sample

      goal_attrs = { title: title, description: description }
      set_if_column!(Goal, goal_attrs, :success_criteria, criteria)
      set_enum_or_activehash!(Goal, goal_attrs, :category,   fallback: label)
      set_enum_or_activehash!(Goal, goal_attrs, :visibility, fallback: "public")

      goal = u.goals.create!(goal_attrs)

      # ------ Logs（直近2週間の見栄え用）------
      7.times do
        log_attrs = { created_at: random_past_datetime }

        mins_col = first_existing_column(Log, %w[minutes duration spent_minutes length])
        log_attrs[mins_col.to_sym] = allowed_minutes_choices.sample if mins_col

        set_any_text_field!(
          Log, log_attrs,
          %w[note memo content body description message text],
          conf[:log_samples].sample
        )

        set_enum_or_activehash!(Log, log_attrs, :visibility, fallback: "public")
        set_enum_or_activehash!(Log, log_attrs, :category,   fallback: label)

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
