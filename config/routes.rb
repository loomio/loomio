Loomio::Application.routes.draw do

  namespace :api, path: '/api/v1' do
    resources :comments, only: :create
  end

  slug_regex = /[a-z0-9\-\_]*/i
  ActiveAdmin.routes(self)

  namespace :admin do
    resource :email_groups, only: [:create, :new]
    resources :stats, only: [] do
      collection do
        get :group_metrics
        get :retention_metrics
        get :events
      end
    end
  end

  get "/explore", to: 'explore#index', as: :explore
  get "/explore/search", to: "explore#search", as: :search_explore
  get "/explore/category/:id", to: "explore#category", as: :category_explore

  resource :search, only: :show

  devise_for :users, controllers: { sessions: 'users/sessions',
                                    registrations: 'users/registrations',
                                    omniauth_callbacks: 'users/omniauth_callbacks' }


  get "/contacts/:importer/callback" => "users/contacts#callback"

  namespace :inbox do
    get   '/', action: 'index'
    get   'size'
    get   'preferences'
    patch   'update_preferences'
    match 'mark_as_read', via: [:get, :post]
    match 'mark_all_as_read/:id', action: 'mark_all_as_read', as: :mark_all_as_read, via: [:get, :post]
    match 'unfollow', via: [:get, :post]
  end

  resources :group_requests, only: [:create, :new] do
    get :confirmation, on: :collection
  end

  resources :invitations, only: [:show, :create, :destroy]

  get "/theme_assets/:id", to: 'theme_assets#show', as: 'theme_assets'

  resources :groups, path: 'g', only: [:new, :create, :edit, :update] do
    member do
      post :join
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

    scope module: :groups do
      resources :memberships, only: [:index, :edit, :destroy, :new, :create] do
        member do
         post :make_admin
         post :remove_admin
        end
      end

      scope controller: 'group_setup' do
        member do
          get :setup
          put :finish
        end
      end

      resources :membership_requests, only: [:create, :new]
      get :membership_requests,  to: 'manage_membership_requests#index', as: 'manage_membership_requests'
    end
  end

  scope module: :groups, path: 'g', slug: slug_regex do
    get    ':id(/:slug)', action: 'show' #, as: :group
    patch    ':id(/:slug)', action: 'update'
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

  constraints(GroupSubdomainConstraint) do
    get '/' => 'groups#show'
    patch '/' => 'groups#update'
  end

  delete 'membership_requests/:id/cancel', to: 'groups/membership_requests#cancel', as: :cancel_membership_request

  resources :motions, path: 'm', only: [:new, :create, :edit, :index] do
    resources :votes, only: [:new, :create, :update]
    member do
      get :history
      patch :close
      patch :create_outcome
      post  :update_outcome
    end
  end

  scope module: :motions, path: 'm', slug: slug_regex do
    get    ':id(/:slug)', action: 'show', as: :motion
    patch  ':id(/:slug)', action: 'update'
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
    get    ':id(/:slug)', action: 'show' #,    as: :discussion
    patch  ':id(/:slug)', action: 'update'
    delete ':id(/:slug)', action: 'destroy'

    post ':id/preview_version/(:version_id)', action: 'preview_version', as: 'preview_version_discussion'
    post 'update_version/:version_id',        action: 'update_version',   as: 'update_version_discussion'
  end

  resources :comments , only: [:destroy, :edit, :update, :show] do
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

  get '/localisation/datetime_input_translations' => 'localisation#datetime_input_translations', format: 'js'

  resources :users, path: 'u', only: [:new] do
    member do
      put :set_avatar_kind
      post :upload_new_avatar
      post :dismiss_system_notice
    end
  end

  scope module: :users do
    match '/profile',          action: 'profile', as: :profile, via: [:get, :post]
    get 'import_contacts' => 'contacts#import'
    get 'autocomplete_contacts' => 'contacts#autocomplete'

    scope module: :email_preferences do
      get   '/email_preferences', action: 'edit',   as: :email_preferences
      put   '/email_preferences', action: 'update', as: :update_email_preferences
      get   '/mark_summary_email_as_read', action: 'mark_summary_email_as_read', as: :mark_summary_email_as_read
    end
  end

  scope module: :users, path: 'u' do
    get ':id(/:slug)', action: 'show',    slug: slug_regex, as: :user
    patch ':id(/:slug)', action: 'update',  slug: slug_regex
  end

  match '/announcements/:id/hide', to: 'announcements#hide', as: 'hide_announcement', via: [:get, :post]
  post '/translate/:model/:id', to: 'translations#create', as: :translate

  get '/users/invitation/accept' => redirect {|params, request|  "/invitations/#{request.query_string.gsub('invitation_token=','')}"}
  get '/group_requests/:id/start_new_group' => redirect {|params, request|  "/invitations/#{request.query_string.gsub('token=','')}"}

  get '/contributions' => redirect('/crowd')
  get '/contributions/thanks' => redirect('/crowd')
  get '/contributions/callback' => redirect('/crowd')
  get '/crowd' => redirect('https://love.loomio.org/')
  get '/groups' => redirect('/explore')

  get '/dashboard', to: 'dashboard#show', as: 'dashboard'
  root :to => 'marketing#index'

  constraints(MainDomainConstraint) do
    scope controller: 'pages' do
      get :about
      get :privacy
      get :purpose
      get :services
      get :terms_of_service
      get :third_parties
      get :try_it
      get :wallets
      get :browser_not_supported
    end
  end

  constraints(GroupSubdomainConstraint) do
    get '/about' => redirect('https://www.loomio.org/about')
    get '/privacy' => redirect('https://www.loomio.org/privacy')
    get '/purpose' => redirect('https://www.loomio.org/purpose')
    get '/services' => redirect('https://www.loomio.org/services')
    get '/terms_of_service' => redirect('https://www.loomio.org/terms_of_service')
    get '/third_parties' => redirect('https://www.loomio.org/third_parties')
    get '/try_it' => redirect('https://www.loomio.org/try_it')
    get '/wallets' => redirect('https://www.loomio.org/wallets')
  end

  scope controller: 'help' do
    get :help
  end

  get '/detect_locale' => 'detect_locale#show'

  resources :contact_messages, only: [:new, :create]
  get 'contact(/:destination)', to: 'contact_messages#new'

  #redirect from wall to new group signup
  namespace :group_requests do
    get 'selection', action: 'new'
    get 'subscription', action: 'new'
    get 'pwyc', action: 'new'
  end

  get '/discussions/:id', to: 'discussions_redirect#show'
  get '/groups/:id',      to: 'groups_redirect#show'
  get '/motions/:id',     to: 'motions_redirect#show'

  get '/users/invitation/accept' => redirect {|params, request|  "/invitations/#{request.query_string.gsub('invitation_token=','')}"}
  get '/group_requests/:id/start_new_group' => redirect {|params, request|  "/invitations/#{request.query_string.gsub('token=','')}"}

  get '/contributions'      => redirect('/crowd')
  get '/contributions/thanks' => redirect('/crowd')
  get '/contributions/callback' => redirect('/crowd')
  get '/crowd'              => redirect('https://love.loomio.org/')

  scope path: 'pages' do
    get 'home'         => redirect('/')
    get 'how*it*works' => redirect('/purpose#how-it-works')
    get 'get*involved' => redirect('/about')
    get 'privacy'      => redirect('/privacy_policy')
    get 'about'        => redirect('/about#about-us')
    match 'contact'    => 'contact_messages#new', via: [:get, :post]
  end

  get '/get*involved'       => redirect('/purpose#how-it-works')
  get '/how*it*works'       => redirect('/purpose#how-it-works')
  get '/about#how-it-works' => redirect('/purpose#how-it-works')

  get '/blog'       => redirect('http://blog.loomio.org')
  get '/press'      => redirect('http://blog.loomio.org/press-pack')
  get '/press-pack' => redirect('http://blog.loomio.org/press-pack')
  get '/roadmap'    => redirect('https://trello.com/b/tM6QGCLH/loomio-roadmap')

  get '/robots'     => 'robots#show'
end
