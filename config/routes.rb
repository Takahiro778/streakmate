Rails.application.routes.draw do
  devise_for :users

  # トップページ
  root "pages#top"
  get "pages/top"

  # 自分専用マイページ
  resource :mypage, only: [:show, :edit, :update], controller: :profiles

  # Goal（目標）
  resources :goals, only: [:index, :new, :create, :show, :edit, :update, :destroy]

  # Log（クイックログ）+ Cheer（応援）
  resources :logs, only: [:index, :create] do
    # /logs/:log_id/cheer (POST: create, DELETE: destroy)
    resource :cheer, only: [:create, :destroy]
  end

  # Timeline（全体/フォロー）
  resources :timeline, only: [:index], controller: :timeline
end
