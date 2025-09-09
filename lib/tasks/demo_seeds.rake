namespace :demo do
  desc "Seed demo users and minimal data (idempotent). In production: CONFIRM=YES bin/rails demo:seed"
  task seed: :environment do
    if Rails.env.production? && ENV["CONFIRM"] != "YES"
      puts "[demo:seed] Refusing to run in production without CONFIRM=YES"
      exit 1
    end

    puts "[demo:seed] Seeding demo users and minimal data..."

    demo_users = [
      {
        nickname: "筋トレ好き太郎",
        email:    "taro@example.com",
        password: "pass12340",
        goals: [
          {
            title:       "毎日30分ランニング",
            description: "無理のないペースで継続。朝ラン中心。",
            logs: [
              { minutes: 30, memo: "ランニング3km" },
              { minutes: 20, memo: "ジムで筋トレ" }
            ]
          }
        ]
      },
      {
        nickname: "夜更かしエンジニア",
        email:    "dev@example.com",
        password: "pass12341",
        goals: [
          {
            title:       "Railsチュートリアル完走",
            description: "毎日少しでも前進する",
            logs: [
              { minutes: 40, memo: "RSpecの章を読んだ" },
              { minutes: 25, memo: "環境構築完了メモ" }
            ]
          }
        ]
      },
      {
        nickname: "朝活サラリーマン",
        email:    "asa@example.com",
        password: "pass12342",
        goals: [
          {
            title:       "早寝早起き習慣",
            description: "23:30就寝、6:30起床を目標にする",
            logs: [
              { minutes: 0, memo: "23:30 就寝" },
              { minutes: 0, memo: "6:30 起床" }
            ]
          }
        ]
      }
    ]

    created_users = []

    demo_users.each do |du|
      user = User.find_or_initialize_by(email: du[:email])
      user.nickname = du[:nickname]
      user.password = du[:password]
      user.save!

      # Profile があれば最低限作成/更新
      if defined?(Profile)
        profile = user.profile || user.build_profile
        profile.display_name ||= du[:nickname]
        profile.save!
      end

      # Settings があればデフォルトセット
      if defined?(Setting) && user.respond_to?(:build_setting) && user.setting.nil?
        user.build_setting.save!
      end

      du[:goals].each do |g|
        goal = user.goals.where(title: g[:title]).first_or_initialize
        goal.description      = g[:description]
        goal.success_criteria ||= "2週間継続"
        # visibility が enum の場合に :public があれば使う
        if goal.class.respond_to?(:defined_enums) && goal.class.defined_enums["visibility"]
          goal.visibility ||= :public
        end
        goal.save!

        g[:logs].each_with_index do |lg, i|
          log = user.logs.where(goal_id: goal.id, memo: lg[:memo]).first_or_initialize
          log.minutes    = lg[:minutes]
          log.memo       = lg[:memo]
          log.goal_id    = goal.id
          # 直近表示用に日付を少しずらす
          log.created_at ||= (Time.current - (i + 1).days).change(hour: [6, 12, 20].sample)
          # visibility が enum の場合に :public があれば使う
          if log.class.respond_to?(:defined_enums) && log.class.defined_enums["visibility"]
            log.visibility ||= :public
          end
          log.save!(validate: false) # minutes nil/enum未設定でも投入しやすく
        end
      end

      created_users << user
    end

    # ちょい体験向け：相互フォロー（存在すれば）
    if defined?(Follow)
      u1, u2, u3 = created_users
      [[u1,u2],[u2,u3],[u3,u1]].each do |a,b|
        next unless a && b
        Follow.find_or_create_by!(follower_id: a.id, followed_id: b.id) rescue nil
      end
    end

    puts "[demo:seed] Done."
  end
end
