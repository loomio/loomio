Tautoko::Application.routes.draw do
  devise_for :users
  resources :groups
  root :to => 'home#index'
end
