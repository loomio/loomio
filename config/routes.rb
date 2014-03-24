Loomio::Application.routes.draw do

  slug_regex = /[a-z0-9\-\_]*/i
  ActiveAdmin.routes(self)

  namespace :admin do
    resource :email_groups, only: [:create, :new]
    resources :stats, only: [] do
      collection do
        get :events
      end
    end
  end

  get "/explore", to: 'explore#index', as: :explore
  get "/groups", to: 'public_groups#index', as: :public_groups

  get "/new_group", to: 'groups#new'

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

  resources :group_requests, only: [:create, :new] do
    get :confirmation, on: :collection
  end

  resources :invitations, only: [:show, :create, :destroy]

  resources :groups, path: 'g', only: [:create, :edit] do
    scope module: :groups do
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
      scope controller: 'group_setup' do
        member do
          get :setup
          put :finish
        end
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

    resources :motions,     only: [:index]
    resources :discussions, only: [:index, :new]
    resources :invitations, only: [:new, :destroy]
  end

  scope module: :groups, path: 'g', slug: slug_regex do
    get    ':id(/:slug)', action: 'show', as: :group
    put    ':id(/:slug)', action: 'update'
    delete ':id(/:slug)', action: 'destroy'

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

  resources :motions, path: 'm', only: [:new, :create, :edit, :index] do
    resources :votes, only: [:new, :create, :update]
    member do
      put :close
      put :create_outcome
      post :update_outcome
      put :edit_close_date
    end
  end

  scope module: :motions, path: 'm', slug: slug_regex do
    get    ':id(/:slug)', action: 'show', as: :motion
    put    ':id(/:slug)', action: 'update'
    delete ':id(/:slug)', action: 'destroy'
  end

  resources :discussions, path: 'd', only: [:new, :edit, :create] do
    get :activity_counts, on: :collection
    resources :invitations, only: [:new]

    member do
      post :update_description
      post :update
      post :add_comment
      post :show_description_history
      get :new_proposal
      post :move
    end
  end

  scope module: :discussions, path: 'd', slug: slug_regex do
    get    ':id(/:slug)', action: 'show',    as: :discussion
    put    ':id(/:slug)', action: 'update'
    delete ':id(/:slug)', action: 'destroy'

    post ':id/preview_version/(:version_id)', action: '#preview_version', as: 'preview_version_discussion'
    post 'update_version/:version_id',        action: 'update_version',   as: 'update_version_discussion'
  end

  resources :comments , only: :destroy do
    post :like, on: :member
    post :translate, on: :member
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

  resources :users, path: 'u', only: [:new] do
    member do
      put :set_avatar_kind
      post :upload_new_avatar
    end
  end

  scope module: :users do
    match '/profile',          action: 'profile', as: :profile
    scope module: :email_preferences do
      get '/email_preferences', action: 'edit',   as: :email_preferences
      put '/email_preferences', action: 'update', as: :update_email_preferences
    end
  end

  scope module: :users, path: 'u' do
    get ':id(/:slug)', action: 'show',    slug: slug_regex, as: :user
    put ':id(/:slug)', action: 'update',  slug: slug_regex
  end

  match '/announcements/:id/hide', to: 'announcements#hide', as: 'hide_announcement'

  get '/users/invitation/accept' => redirect {|params, request|  "/invitations/#{request.query_string.gsub('invitation_token=','')}"}
  get '/group_requests/:id/start_new_group' => redirect {|params, request|  "/invitations/#{request.query_string.gsub('token=','')}"}

  get '/contributions' => redirect('/crowd')
  get '/contributions/thanks' => redirect('/crowd')
  get '/contributions/callback' => redirect('/crowd')
  get '/crowd' => redirect('https://love.loomio.org/')

  # resources :contributions, only: [:index, :create] do
  #   get :callback, on: :collection
  #   get :thanks, on: :collection
  # end

  get '/dashboard', to: 'dashboard#show', as: 'dashboard'
  root :to => 'marketing#index'

  scope controller: 'pages' do
    get :about
    get :privacy
    get :purpose
    get :services
    get :terms_of_service
    get :third_parties
    get :wallets
    get :browser_not_supported
  end

  scope controller: 'campaigns' do
    get :hide_crowdfunding_banner
  end

  scope controller: 'help' do
    get :help
  end

  get '/detect_locale' => 'detect_locale#show'
  match '/detect_video_locale' => 'detect_locale#video', as: :detect_video_locale

  resources :contact_messages, only: [:new, :create]
  match 'contact(/:destination)', to: 'contact_messages#new'

  #redirect from wall to new group signup
  namespace :group_requests do
    get 'selection', action: 'new'
    get 'subscription', action: 'new'
    get 'pwyc', action: 'new'
  end

  #redirect old invites
  match "/groups/:id/invitations/:token" => "group_requests#start_new_group"

  #redirect old pages:
  get '/we_the_people' => redirect('/')
  get '/collaborate'   => redirect('/')
  get '/woc'           => redirect('/')
  get '/discussions/:id', to: 'discussions_redirect#show'
  get '/groups/:id',      to: 'groups_redirect#show'
  get '/motions/:id',     to: 'motions_redirect#show'

  scope path: 'pages' do
    get 'home'         => redirect('/')
    get 'how*it*works' => redirect('/purpose#how-it-works')
    get 'get*involved' => redirect('/about')
    get 'privacy'      => redirect('/privacy_policy')
    get 'about'        => redirect('/about#about-us')
    match 'contact'    => 'contact_messages#new'
  end

  get '/get*involved'       => redirect('/purpose#how-it-works')
  get '/how*it*works'       => redirect('/purpose#how-it-works')
  get '/about#how-it-works' => redirect('/purpose#how-it-works')

  get '/blog'       => redirect('http://blog.loomio.org')
  get '/press'      => redirect('http://blog.loomio.org/press-pack')
  get '/press-pack' => redirect('http://blog.loomio.org/press-pack')
end
