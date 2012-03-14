Tautoko::Application.routes.draw do
  devise_for :users

  # Routes for jQuery TokenInput API calls and tag specific calls
  get "/groups/:id/user/:user_id/user_group_tags" => "groups#user_group_tags", :as => "user_group_tags"
  get "/groups/:id/group_tags" => "groups#group_tags", :as => "group_tags"
  match "/groups/:id/user/:user_id/add_user_tag/:tag", :to => "groups#add_user_tag", :as => :add_user_tag
  match "/groups/:id/user/:user_id/delete_user_tag/:tag", :to => "groups#delete_user_tag", :as => :delete_user_tag
  match "/groups/:id/tag_user", :to => "groups#tag_user", :as => :group_tag_user

  resources :groups do
    resources :motions, name_prefix: "groups_"
    get :request_membership, on: :member
  end
  resources :motions do
    resources :votes
  end
  match "/motions/:id/close", :to => "motions#close_voting", :as => :close_motion_voting,
    :via => :post

  match "/motions/:id/open", :to => "motions#open_voting", :as => :open_motion_voting,
    :via => :post

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
