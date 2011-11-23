Tautoko::Application.routes.draw do
  devise_for :users
  resources :groups do
    resources :motions
  end
  root :to => 'home#index'
end
