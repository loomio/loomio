Loomio::Application.routes.draw do
  ActiveAdmin.routes(self)

  devise_for :users, controllers: { sessions: 'users/sessions', 
                                    invitations: 'users/invitations' }

  resources :group_requests, only: [:create, :new] do
    get :start_new_group, on: :member
  end

  match "/request_new_group", to: "group_requests#start", as: :request_new_group
  match "/group_request_confirmation", to: "group_requests#confirmation", as: :group_request_confirmation

  resources :groups, except: [:index, :new] do
    post :add_members, on: :member
    get :add_subgroup, on: :member
    resources :motions#, name_prefix: "groups_"
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
    get :dropdown_items, on: :collection
    post :mark_as_viewed, :on => :collection, :via => :post
  end

  resources :memberships, except: [:new, :update, :show] do
    post :make_admin, on: :member
    post :remove_admin, on: :member
    post :approve_request, on: :member, as: :approve_request_for
    post :ignore_request, on: :member, as: :ignore_request_for
    post :cancel_request, on: :member, as: :cancel_request_for
  end

  resources :users, :only => [:new, :create, :update, :show,] do
    put :set_avatar_kind, on: :member
    post :upload_new_avatar, on: :member
  end

  match '/announcements/:id/hide', to: 'announcements#hide', as: 'hide_announcement'

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
  match 'email_preferences', :to => "email_preferences#edit", :as => :email_preferences, :via => :get
  match 'email_preferences', :to => "email_preferences#update", :as => :update_email_preferences, :via => :put

  authenticated do
    root :to => 'dashboard#show'
  end

  root :to => 'pages#home'

  scope controller: 'pages' do
    get :about
    get :privacy
    get :browser_not_supported
  end

  resources :woc, only: :index do
    post :send_request, on: :collection
  end
  get '/collaborate', to: "woc#index", as: :collaborate

  #redirect old invites
  match "/groups/:id/invitations/:token" => "group_requests#start_new_group"

  #redirect old pages:
  get '/pages/how*it*works' => redirect('/about#how-it-works')
  get '/get*involved' => redirect('/about#how-it-works')
  get '/how*it*works' => redirect('/about#how-it-works')
  get '/pages/get*involved' => redirect('/about')
  get '/pages/about' => redirect('/about#about-us')
  get '/pages/contact' => redirect('/about#about-us')
  get '/contact' => redirect('/about#about-us')
  get '/pages/privacy' => redirect('/privacy_policy')
end
