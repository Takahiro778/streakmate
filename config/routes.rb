Rails.application.routes.draw do
  devise_for :users

  # トップページ
  root "pages#top"
  get "pages/top"

  # 自分専用マイページ
  resource :mypage, only: [:show, :edit, :update], controller: :profiles

  # Goal（目標）
  resources :goals, only: [:index, :new, :create, :show, :edit, :update, :destroy]

  # Log（クイックログ）+ Cheer（応援）+ Comment（コメント）
  resources :logs, only: [:index, :create] do
    # /logs/:log_id/cheer (POST: create, DELETE: destroy)
    resource  :cheer,    only: [:create, :destroy]
    # /logs/:log_id/comments/:id
    resources :comments, only: [:create, :edit, :update, :destroy]
  end

  # Follow（ユーザーに対するフォロー/解除）— 単数リソースでトグル
  resources :users, only: [] do
    # POST   /users/:user_id/follow   -> follows#create
    # DELETE /users/:user_id/follow   -> follows#destroy
    resource :follow, only: [:create, :destroy]
  end

  # Timeline（全体/フォロー）
  resources :timeline, only: [:index], controller: :timeline
end
