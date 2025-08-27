Rails.application.routes.draw do
  devise_for :users
  root "pages#top"
  get "pages/top"
end
