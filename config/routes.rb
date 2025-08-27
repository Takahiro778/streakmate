Rails.application.routes.draw do
  devise_for :users

  root "pages#top"
  get "pages/top"

  # マイページ（自分専用のプロフィール）
  resource :mypage, only: [:show, :edit, :update], controller: :profiles
end
