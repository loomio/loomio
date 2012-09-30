Loomio::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :users, :controllers => { :invitations => 'users/invitations' }

  resources :groups, except: :index do
    post :add_members, on: :member
    get :add_subgroup, on: :member
    resources :motions#, name_prefix: "groups_"
    resources :discussions, only: :index
    get :request_membership, on: :member
    get :new_motion, :on => :member
    post :create_motion, :on => :member
    post :email_members, on: :member
    post :edit_description, :on => :member
  end

  match "/groups/archive/:id", :to => "groups#archive", :as => :archive_group, :via => :post

  resources :motions do
    resources :votes
    put :edit_outcome, :on => :member
  end
  match "/motions/:id/close", :to => "motions#close_voting", :as => :close_motion_voting,
        :via => :post
  match "/motions/:id/open", :to => "motions#open_voting", :as => :open_motion_voting,
        :via => :post

  resources :discussions, only: [:index, :show, :create, :update] do
    post :edit_description, :on => :member
    post :add_comment, :on => :member
    get :new_proposal, :on => :member
    post :edit_title, :on => :member
  end

  resources :notifications, :only => :index do
    post :mark_as_viewed, :on => :collection, :via => :post
  end

  resources :votes

  resources :memberships, except: [:new, :update, :show] do
    post :make_admin, on: :member
    post :remove_admin, on: :member
    post :approve_request, on: :member, as: :approve_request_for
    post :ignore_request, on: :member, as: :ignore_request_for
    post :cancel_request, on: :member, as: :cancel_request_for
  end

  resources :users do
    post :set_avatar_kind, on: :member
    post :upload_new_avatar, on: :member
    get :mentions, on: :collection
  end
  match "/users/dismiss_system_notice", :to => "users#dismiss_system_notice",
        :as => :dismiss_system_notice_for_user, :via => :post
  match "/users/dismiss_dashboard_notice", :to => "users#dismiss_dashboard_notice",
        :as => :dismiss_dashboard_notice_for_user, :via => :post
  match "/users/dismiss_group_notice", :to => "users#dismiss_group_notice",
        :as => :dismiss_group_notice_for_user, :via => :post
  match "/users/dismiss_discussion_notice", :to => "users#dismiss_discussion_notice",
        :as => :dismiss_discussion_notice_for_user, :via => :post

  resources :comments, only: :destroy do
    post :like, on: :member
    post :unlike, on: :member
  end
  match "/settings", :to => "users#settings", :as => :user_settings

  # route logged in user to dashboard
  resources :dashboard, only: :show
  authenticated do
    root :to => 'dashboard#show'
  end
  # route logged out user to landing page
  resources :landing, only: :show
  root :to => 'landing#show'
  match '/demo' => 'landing#demo'
  match '/browser_not_supported' => 'landing#browser_not_supported',
    :as => :browser_not_supported
end
