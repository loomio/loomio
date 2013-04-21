Loomio::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :users, controllers: { sessions: 'users/sessions' }

  resources :invitations, only: [:show]

  resources :group_requests, only: [:create, :new] do
    get :verify, on: :member
    get :start_new_group, on: :member
  end
  
  match "/request_new_group", to: "group_requests#start", as: :request_new_group
  match "/group_request_confirmation", to: "group_requests#confirmation", as: :group_request_confirmation

  resources :groups, except: [:index, :new] do
    resources :invitations, only: [:index, :destroy, :new, :create], controller: 'groups/invitations'
    resources :memberships, only: [:index, :destroy, :new, :create], controller: 'groups/memberships' do
      member do
       post :make_admin
       post :remove_admin

       # these three (and #new) are for membership requests which I hope to split off into a new class
       post :approve_request, as: :approve_request_for
       post :ignore_request, as: :ignore_request_for
       post :cancel_request, as: :cancel_request_for
      end
    end

    get :setup, on: :member, to: 'groups/group_setup#setup'
    post :finish, on: :member, to: 'groups/group_setup#finish'
    post :add_members, on: :member
    get :add_subgroup, on: :member
    resources :motions
    resources :discussions, only: [:index, :new]
    get :request_membership, on: :member
    post :email_members, on: :member
    post :edit_description, on: :member
    post :edit_privacy, on: :member
    delete :leave_group, on: :member
  end

  match "/groups/archive/:id", :to => "groups#archive", :as => :archive_group, :via => :post
  match "/groups/:id/members", :to => "groups#get_members", :as => :get_members, :via => :get

  resources :motions do
    resources :votes, only: [:new, :edit, :create, :update]
    post :get_and_clear_new_activity, on: :member
    put :close, :on => :member
    put :edit_outcome, :on => :member
    put :edit_close_date, :on => :member
  end

  resources :discussions, except: [:edit] do
    post :edit_description, :on => :member
    post :add_comment, :on => :member
    post :show_description_history, :on => :member
    get :new_proposal, :on => :member
    post :edit_title, :on => :member
    put :move, :on => :member
  end
  post "/discussion/:id/preview_version/(:version_id)", :to => "discussions#preview_version", :as => "preview_version_discussion"
  post "/discussion/update_version/:version_id", :to => "discussions#update_version", :as => "update_version_discussion"

  resources :notifications, :only => :index do
    post :mark_as_viewed, :on => :collection, :via => :post
  end


  resources :users do
    put :edit_name, on: :member
    put :set_avatar_kind, on: :member
    post :upload_new_avatar, on: :member
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
  match 'email_preferences', :to => "users/email_preferences#edit", :as => :email_preferences, :via => :get
  match 'email_preferences', :to => "users/email_preferences#update", :as => :update_email_preferences, :via => :put

  # route logged in user to dashboard
  resources :dashboard, only: :show

  authenticated do
    root :to => 'dashboard#show'
  end

  #redirect old invites
  match "/groups/:id/invitations/:token" => "group_requests#start_new_group"

  match '/browser_not_supported' => 'high_voltage/pages#show', :id => 'browser_not_supported'
  match '/privacy' => 'high_voltage/pages#show', :id => 'privacy'
  match '/blog' => 'high_voltage/pages#show', :id => 'blog'
  match '/collaborate', to: "woc#index", as: :collaborate

  root :to => 'pages#show', :id => 'home'

  #redirect old pages:
  match '/pages/how*it*works' => redirect('/pages/home#how')
  match '/pages/get*involved' => redirect('/pages/home#who')
  match '/how*it*works' => redirect('/pages/home#how')
  match '/get*involved' => redirect('/pages/home#who')
  match '/pages/about' => redirect('/pages/home#who')
  match '/pages/contact' => redirect('/pages/home#who')
  match '/pages/blog' => redirect('/pages/home/blog')
  match '/pages/privacy' => redirect('/pages/home/privacy')
  match '/about' => redirect('/pages/home#who')
  match '/contact' => redirect('/pages/home#who')
  match '/demo' => redirect('/')

  match "/pages/*id" => 'pages#show', :as => :page, :format => false

  resources :woc, only: :index do
    post :send_request, on: :collection
  end
end
