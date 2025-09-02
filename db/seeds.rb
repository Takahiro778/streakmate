# --- 本番では実行しない ---
if Rails.env.production?
  puts "[seeds] Skip on production"
  return
end

require "faker"
Faker::Config.locale = :ja

# ---------------- ヘルパ ----------------

# カラムが存在するときだけ値を入れる
def set_if_column!(model_class, attrs, name, value)
  attrs[name] = value if model_class.column_names.include?(name.to_s)
end

# 候補のうち最初に存在するカラム名を返す
def first_existing_column(model_class, candidates)
  candidates.find { |n| model_class.column_names.include?(n) }
end

# 複数候補（note, memo, ...）のうち存在するテキスト列へ値を入れる
def set_any_text_field!(model_class, attrs, candidates, value)
  col = first_existing_column(model_class, candidates)
  attrs[col.to_sym] = value if col
end

# enum / ActiveHash / string / integer のいずれでもいい感じにセット
# 例: set_enum_or_activehash!(Goal, goal_attrs, :category)
def set_enum_or_activehash!(model_class, attrs, name, fallback: "public")
  name_s = name.to_s

  # 1) ActiveRecord enum（キー名で入れるのが安全）
  if model_class.respond_to?(:defined_enums) && model_class.defined_enums.key?(name_s)
    attrs[name] = model_class.defined_enums[name_s].keys.first
    return true
  end

  # 2) ActiveHash（*_id カラムがあり、関連から実在IDを拾う）
  id_col = "#{name_s}_id"
  if model_class.column_names.include?(id_col)
    assoc_klass =
      begin
        model_class.reflect_on_association(name)&.klass
      rescue StandardError
        nil
      end

    first_id =
      begin
        assoc_klass&.all&.first&.id
      rescue StandardError
        nil
      end

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

# Log.minutes の inclusion バリデータを読んで、許容セットから選ぶ
def allowed_minutes_choices
  return [10, 15, 20, 25, 30, 45, 60, 75, 90, 120] unless defined?(Log)

  inclusion = Log.validators_on(:minutes).find { |v| v.is_a?(ActiveModel::Validations::InclusionValidator) }
  set = inclusion&.options&.dig(:in)
  set.respond_to?(:to_a) ? set.to_a : [10, 15, 20, 25, 30, 45, 60, 75, 90, 120]
end

def random_past_datetime
  rand(0..14).days.ago.change(hour: [6, 9, 12, 15, 20].sample)
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
  users = 10.times.map do |i|
    User.create!(
      nickname: Faker::Name.name,
      email:    Faker::Internet.unique.email,
      password: "pass1234#{i}" # 英字+数字
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
  users.each do |u|
    2.times do
      # ------ Goal ------
      goal_attrs = {
        title:       Faker::Lorem.words(number: 3).join(" "),
        description: Faker::Lorem.paragraph_by_chars(number: 120)
      }
      set_if_column!(Goal, goal_attrs, :success_criteria, Faker::Lorem.sentence)
      set_enum_or_activehash!(Goal, goal_attrs, :category)
      set_enum_or_activehash!(Goal, goal_attrs, :visibility)

      goal = u.goals.create!(goal_attrs)

      # ------ Logs（見栄え用 5件）------
      5.times do
        log_attrs = { created_at: random_past_datetime }

        # minutes / duration / spent_minutes / length のどれかに許容値をセット
        mins_col = first_existing_column(Log, %w[minutes duration spent_minutes length])
        if mins_col
          log_attrs[mins_col.to_sym] = allowed_minutes_choices.sample
        end

        # テキスト列（存在するものだけ）
        set_any_text_field!(Log, log_attrs, %w[note memo content body description message text], Faker::Lorem.sentence)

        # Log 側の visibility / category など（存在すれば）も安全にセット
        set_enum_or_activehash!(Log, log_attrs, :visibility)
        set_enum_or_activehash!(Log, log_attrs, :category)

        # 関連があれば付与
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
