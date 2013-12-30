Loomio::Application.routes.draw do
  ActiveAdmin.routes(self)

  namespace :admin do
    resource :email_groups, only: [:create, :new]
    resources :stats, only: [] do
      collection do
        get :events
      end
    end
  end

  get "/groups", to: 'public_groups#index', as: :public_groups

  resource :search, only: :show

  devise_for :users, controllers: { sessions: 'users/sessions',
                                    registrations: 'users/registrations',
                                    omniauth_callbacks: 'users/omniauth_callbacks' }

  namespace :inbox do
    get   '/', action: 'index'
    get   'size'
    get   'preferences'
    put   'update_preferences'
    match 'mark_as_read'
    match 'mark_all_as_read/:id', action: 'mark_all_as_read', as: :mark_all_as_read
    match 'unfollow'
  end

  resources :invitations, only: [:show]

  resources :group_requests, only: [:create, :new] do
    collection do
      get :confirmation
    end
  end

  resources :groups, path: 'g', except: [:index, :new, :show, :update] do
    scope module: :groups do
      resources :invitations, only: [:index, :destroy, :new, :create]
      resources :memberships, only: [:index, :destroy, :new, :create] do
        member do
         post :make_admin
         post :remove_admin
        end
      end
      resource :subscription, controller: 'subscriptions', only: [:new, :show] do
        collection do
          post :checkout
          get :confirm
          get :payment_failed
        end
      end
      member do
        get :setup,  controller: 'group_setup'
        put :finish, controller: 'group_setup'
      end

      get :ask_to_join, controller: 'membership_requests', action: :new
      resources :membership_requests, only: [:create]
      get :membership_requests,  to: 'manage_membership_requests#index', as: 'membership_requests'
    end

    member do
      post :add_members
      post :hide_next_steps
      get :add_subgroup
      post :email_members
      post :edit_description
      delete :leave_group
      get :members_autocomplete
    end

    resources :motions
    resources :discussions, only: [:index, :new]
  end

  scope module: :groups, path: 'g' do
    get ':id(/:slug)',   action: 'show',   slug: /[a-zA-Z0-9-]*/, as: :group
    put ':id/:slug',     action: 'update', slug: /[a-zA-Z0-9-]*/ #this catches the edit group form

    post 'archive/:id',  action: 'archive', as: :archive_group
  end

  scope module: :groups do
    resources :manage_membership_requests, only: [], as: 'membership_requests' do
      member do
        post :approve
        post :ignore
      end
    end
  end

  delete 'membership_requests/:id/cancel', to: 'groups/membership_requests#cancel', as: :cancel_membership_request

  resources :motions do
    resources :votes, only: [:new, :create, :update]
    member do
      put :close
      put :create_outcome
      post :update_outcome
      put :edit_close_date
    end
  end

  resources :discussions, path: 'd', except: [:index, :show, :edit] do
    get :activity_counts, on: :collection

    member do
      post :update_description
      post :add_comment
      post :show_description_history
      get :new_proposal
      post :edit_title
      put :move
    end
  end

  scope module: :discussions, path: 'd' do
    get    ':id(/:slug)', action: 'show',    slug: /[a-zA-Z0-9-]*/, as: :discussion
    delete ':id/:slug',   action: 'destroy', slug: /[a-zA-Z0-9-]*/

    post ':id/preview_version/(:version_id)', action: '#preview_version', as: 'preview_version_discussion'
    post 'update_version/:version_id',        action: 'update_version',   as: 'update_version_discussion'
  end

  resources :comments , only: :destroy do
    post :like, on: :member
  end

  resources :attachments, only: [:create, :new] do
    collection do
      get 'sign'
      get :iframe_upload_result
    end
  end

  resources :notifications, :only => :index do
    collection do
      get :groups_tree_dropdown
      get :dropdown_items
      post :mark_as_viewed
    end
  end

  resources :users, :only => [:new, :update, :show] do
    member do
      put :set_avatar_kind
      post :upload_new_avatar
    end
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


  get '/users/invitation/accept' => redirect {|params, request|  "/invitations/#{request.query_string.gsub('invitation_token=','')}"}
  get '/group_requests/:id/start_new_group' => redirect {|params, request|  "/invitations/#{request.query_string.gsub('token=','')}"}

  match "/settings", :to => "users#settings", :as => :user_settings
  match 'email_preferences', :to => "users/email_preferences#edit", :as => :email_preferences, :via => :get
  match 'email_preferences', :to => "users/email_preferences#update", :as => :update_email_preferences, :via => :put

  resources :contributions, only: [:index, :create] do
    get :callback, on: :collection
    get :thanks, on: :collection
  end

  authenticated do
    root :to => 'dashboard#show'
  end

  root :to => 'pages#home'

  scope controller: 'pages' do
    get :about
    get :privacy
    get :purpose
    get :pricing
    get :terms_of_service
    get :browser_not_supported
  end

  scope controller: 'help' do
    get :help
  end

  get 'we_the_people' => redirect('/')
  get 'collaborate' => redirect('/')
  get 'woc' => redirect('/')

  resources :contact_messages, only: [:new, :create,]
  match '/contact', to: 'contact_messages#new'

  #redirect from wall to new group signup
  get "group_requests/selection", to: "group_requests#new"
  get "group_requests/subscription", to: "group_requests#new"
  get "group_requests/pwyc", to: "group_requests#new"

  #redirect old invites
  match "/groups/:id/invitations/:token" => "group_requests#start_new_group"

  #redirect old pages:
  get '/pages/home' => redirect('/')
  get '/get*involved' => redirect('/purpose#how-it-works')
  get '/how*it*works' => redirect('/purpose#how-it-works')
  get '/about#how-it-works' => redirect('/purpose#how-it-works')
  get '/pages/how*it*works' => redirect('/purpose#how-it-works')
  get '/pages/get*involved' => redirect('/about')
  get '/pages/privacy' => redirect('/privacy_policy')
  get '/pages/about' => redirect('/about#about-us')
  match '/pages/contact', to: 'contact_messages#new'

  get 'discussions/:id', to: 'discussions_redirect#show'
  get 'groups/:id',      to: 'groups_redirect#show'

  get 'blog' => redirect('http://blog.loomio.org')
  get 'press' => redirect('http://blog.loomio.org/press-pack')
  get 'press-pack' => redirect('http://blog.loomio.org/press-pack')

  get '/generate_error', to: 'generate_error#new'
end
