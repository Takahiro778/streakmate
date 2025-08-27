Rails.application.routes.draw do
  devise_for :users

  root "pages#top"
  get "pages/top"

  # 自分専用マイページ
  resource :mypage, only: [:show, :edit, :update], controller: :profiles
end
