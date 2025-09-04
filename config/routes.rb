Rails.application.routes.draw do
  devise_for :users

  # 🌐 公開トップページ（OGP 用のランディング）
  root "home#show"
  get "home", to: "home#show"

  # 自分専用マイページ
  resource :mypage, only: [:show, :edit, :update], controller: :profiles

  # ✅ 就寝リマインダー等の設定（単一リソース）
  resource :setting, only: [:show, :update]

  # Goal（目標）
  resources :goals, only: [:index, :new, :create, :show, :edit, :update, :destroy] do
    # Favorite（ブックマーク）: /goals/:goal_id/favorite
    resource :favorite, only: [:create, :destroy]
  end

  # Log（クイックログ）+ Cheer（応援）+ Comment（コメント）
  resources :logs, only: [:index, :show, :create] do
    resource  :cheer,    only: [:create, :destroy]
    resources :comments, only: [:create, :edit, :update, :destroy]
  end

  # Follow（ユーザーに対するフォロー/解除）+ プロフィール表示
  resources :users, only: [:show] do
    resource :follow, only: [:create, :destroy]
  end

  # Timeline（全体/フォロー）
  resources :timeline, only: [:index], controller: :timeline

  # ✅ Notifications（一覧・既読化・一括既読）
  resources :notifications, only: [:index, :update] do
    patch :read_all, on: :collection
  end

  # ✅ Suggestions（ワンタップ提案）
  resources :suggestions, only: :create

  # ✅ Guides（/guides/:id → relax / sleep）
  resources :guides, only: :show

  # 404 と 500 のエラーページ
  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all

  # ヘルスチェック
  get "/up", to: proc { [200, {"Content-Type" => "text/plain"}, ["OK"]] }
end
