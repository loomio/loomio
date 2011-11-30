Tautoko::Application.routes.draw do
  devise_for :users

  resources :groups do
    resources :motions
    get :request_membership, on: :member
  end
  resources :memberships
  resources :votes

  namespace :admin do
    resources :groups
  end
  match "/admin", :to => redirect("/admin/groups")

  root :to => 'home#index'
end
