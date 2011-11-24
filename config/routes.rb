Tautoko::Application.routes.draw do
  devise_for :users
  resources :groups do
    resources :motions
  end
  resources :memberships
  root :to => 'home#index'
end
