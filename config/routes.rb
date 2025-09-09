Rails.application.routes.draw do
  devise_for :users

  # 🌐 公開トップ（OGP 用ランディング）
  root "home#show"
  get  "home", to: "home#show"

  # 👤 マイページ（プロフィール）
  resource :mypage,  only: %i[show edit update], controller: :profiles

  # ⚙️ 個別設定（就寝リマインダー等）
  resource :setting, only: %i[update]

  # 🎯 Goal（目標）
  resources :goals, only: %i[index new create show edit update destroy] do
    # ⭐ Favorite（ブックマーク）: /goals/:goal_id/favorite
    resource :favorite, only: %i[create destroy]

    # ✅ ゴール配下タスク（Todo）
    resources :goal_tasks, only: %i[create update destroy] do
      collection { patch :reorder }  # /goals/:goal_id/goal_tasks/reorder
      member     { patch :move }     # /goals/:goal_id/goal_tasks/:id/move
    end
  end

  # 📝 Log（クイックログ）+ 🎉 Cheer + 💬 Comment
  resources :logs, only: %i[index show create destroy] do
    resource  :cheer,    only: %i[create destroy]
    resources :comments, only: %i[create edit update destroy]
  end

  # ➕ Follow（ユーザーに対するフォロー/解除）+ プロフィール表示
  resources :users, only: %i[show] do
    resource :follow, only: %i[create destroy]
  end

  # 📰 Timeline（全体/フォロー）— アクティビティタブの遷移先
  resources :timeline, only: %i[index], controller: :timeline

  # 🔔 Notifications（一覧・既読化・一括既読）
  resources :notifications, only: %i[index update] do
    patch :read_all, on: :collection
  end

  # 🤖 Suggestions（ワンタップ提案）
  resources :suggestions, only: %i[create]

  # 📘 Guides（/guides/:id → relax / sleep）
  resources :guides, only: %i[show]

  # ☰ 汎用メニュー（フッターの「その他」）
  get "more", to: "pages#more"

  # ❌ エラーページ
  match "/404", to: "errors#not_found",             via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  # 🩺 Health Check（Render 用・超軽量）
  get "/up", to: proc { [200, { "Content-Type" => "text/plain" }, ["OK"]] }
end
