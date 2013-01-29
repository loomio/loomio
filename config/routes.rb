  Loomio::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :users, :controllers => { :invitations => 'users/invitations' }

  resources :group_requests, :only => [:create, :new]
  match "/request_new_group", :to => "group_requests#start", :as => :request_new_group
  match "/group_request_confirmation", :to => "group_requests#confirmation", :as => :group_request_confirmation

  resources :groups, except: :index do
    resources :invitations, :only => :show
    post :add_members, on: :member
    get :add_subgroup, on: :member
    resources :motions#, name_prefix: "groups_"
    resources :discussions, only: [:index, :new]
    get :request_membership, on: :member
    post :email_members, on: :member
    post :edit_description, :on => :member
    post :edit_privacy, on: :member
  end

  match "/groups/archive/:id", :to => "groups#archive", :as => :archive_group, :via => :post
  match "/groups/:id/members", :to => "groups#get_members", :as => :get_members, :via => :get

  resources :motions do
    resources :votes
    post :get_and_clear_new_activity, on: :member
    put :close, :on => :member
    put :edit_outcome, :on => :member
    put :edit_close_date, :on => :member
  end

  resources :discussions, except: [:destroy, :edit] do
    post :edit_description, :on => :member
    post :add_comment, :on => :member
    post :show_description_history, :on => :member
    get :new_proposal, :on => :member
    post :edit_title, :on => :member
  end
  post "/discussion/:id/preview_version/(:version_id)", :to => "discussions#preview_version", :as => "preview_version_discussion"
  post "/discussion/update_version/:version_id", :to => "discussions#update_version", :as => "update_version_discussion"

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
    post :set_markdown, on: :member
  end

  match "/users/dismiss_system_notice", :to => "users#dismiss_system_notice",
        :as => :dismiss_system_notice_for_user, :via => :post
  match "/users/dismiss_dashboard_notice", :to => "users#dismiss_dashboard_notice",
        :as => :dismiss_dashboard_notice_for_user, :via => :post
  match "/users/dismiss_group_notice", :to => "users#dismiss_group_notice",
        :as => :dismiss_group_notice_for_user, :via => :post
  match "/users/dismiss_discussion_notice", :to => "users#dismiss_discussion_notice",
        :as => :dismiss_discussion_notice_for_user, :via => :post

  resources :comments , only: :destroy do
    post :like, on: :member
    post :unlike, on: :member
  end
  match "/settings", :to => "users#settings", :as => :user_settings
  match 'email_preferences', :to => "users#email_preferences", :as => :email_preferences

  # route logged in user to dashboard
  resources :dashboard, only: :show

  authenticated do
    root :to => 'dashboard#show'
  end



  root :to => 'high_voltage/pages#show', :id => 'home'

  match '/browser_not_supported' => 'high_voltage/pages#show', :id => 'browser_not_supported'
  match '/privacy' => 'high_voltage/pages#show', :id => 'privacy'
  match '/blog' => 'high_voltage/pages#show', :id => 'blog'

  #redirect old pages:
  match '/pages/how*it*works' => redirect('/pages/home#how')
  match '/pages/get*involved' => redirect('/pages/home#who')
  match '/pages/about' => redirect('/pages/home#who')
  match '/pages/contact' => redirect('/pages/home#who')
  match '/pages/blog' => redirect('/pages/home/blog')
  match '/pages/privacy' => redirect('/pages/home/privacy')
  match '/how*it*works' => redirect('/pages/home#how')
  match '/get*involved' => redirect('/pages/home#who')
  match '/about' => redirect('/pages/home#who')
  match '/contact' => redirect('/pages/home#who')
  match '/demo' => redirect('/')
end
