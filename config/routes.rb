Rails.application.routes.draw do
  devise_for :users
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  resources :posts do
    resources :comments, only: [:create, :edit, :update, :destroy]
  end
  root 'posts#index'
  resources :categories, only: :show

  resources :users, only: [:show, :edit, :update]

  namespace :admin do
    resources :users, only: [:index, :edit, :update]
    resources :categories, except: [:show, :new, :edit]
    root 'categories#index'
  end
end