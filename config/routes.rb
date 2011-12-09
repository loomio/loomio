Tautoko::Application.routes.draw do
  devise_for :users

  resources :groups do
    resources :motions, name_prefix: "groups_"
    get :request_membership, on: :member
  end
  resources :motions do
    resources :votes
  end

  resources :votes
  resources :memberships
  resources :users
  match "/settings", :to => "users#settings", :as => :user_settings

  namespace :admin do
    resources :groups
  end
  match "/admin", :to => redirect("/admin/groups")

  root :to => 'home#index'
end
