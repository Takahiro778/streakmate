Rails.application.routes.draw do
  devise_for :users

  # トップページ
  root "pages#top"
  get "pages/top"

  # 自分専用マイページ
  resource :mypage, only: [:show, :edit, :update], controller: :profiles

  # Goal（目標）投稿：タイムライン・新規作成
  resources :goals, only: [:index, :new, :create, :show, :edit, :update, :destroy]

  # Log（クイックログ）投稿：自分用
  resources :logs, only: [:index, :create]

  # Timeline（全体/フォロー）
  resources :timeline, only: [:index], controller: :timeline
end
