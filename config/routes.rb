Tautoko::Application.routes.draw do
  devise_for :users
  resources :groups do
    resources :motions
    get :request_membership, on: :member
  end
  resources :memberships
  root :to => 'home#index'
end
