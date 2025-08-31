Rails.application.routes.draw do
  devise_for :users

  # トップページ
  root "pages#top"
  get "pages/top"

  # 自分専用マイページ
  resource :mypage, only: [:show, :edit, :update], controller: :profiles

  # Goal（目標）
  resources :goals, only: [:index, :new, :create, :show, :edit, :update, :destroy] do
    # Favorite（ブックマーク）: /goals/:goal_id/favorite
    # POST -> favorites#create / DELETE -> favorites#destroy
    resource :favorite, only: [:create, :destroy]
  end

  # Log（クイックログ）+ Cheer（応援）+ Comment（コメント）
  resources :logs, only: [:index, :create] do
    resource  :cheer,    only: [:create, :destroy]                 # /logs/:log_id/cheer
    resources :comments, only: [:create, :edit, :update, :destroy] # /logs/:log_id/comments/:id
  end

  # Follow（ユーザーに対するフォロー/解除）+ プロフィール表示
  resources :users, only: [:show] do
    # POST /users/:user_id/follow -> follows#create
    # DELETE /users/:user_id/follow -> follows#destroy
    resource :follow, only: [:create, :destroy]
  end

  # Timeline（全体/フォロー）
  resources :timeline, only: [:index], controller: :timeline

  # ✅ Notifications（一覧・既読化・一括既読）
  resources :notifications, only: [:index, :update] do
    patch :read_all, on: :collection
  end

  # （任意）ヘルスチェック
  # get "/up", to: proc { [200, {"Content-Type" => "text/plain"}, ["OK"]] }
end
