Rails.application.routes.draw do
  devise_for :users

  root "pages#top"
  get "pages/top"

  # 自分専用マイページ
  resource :mypage, only: [:show, :edit, :update], controller: :profiles

  # Goal（目標）投稿：タイムライン・新規作成
  resources :goals, only: [:index, :new, :create, :show, :edit, :update, :destroy]
end
