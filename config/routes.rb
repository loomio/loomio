Loomio::Application.routes.draw do

  scope '/angular_support', controller: 'angular_support', path: 'angular_support', as: 'angular_support' do
    get 'setup_for_invite_people'
    get 'setup_for_add_comment'
    get 'setup_for_like_comment'
    get 'setup_for_vote_on_proposal'
  end

  get '/angular' => 'base#boot_angular_ui'


  slug_regex = /[a-z0-9\-\_]*/i

  ActiveAdmin.routes(self)

  namespace :admin do
    namespace :stats do
      get :group_activity
      get :daily_activity
      get :first_30_days
      get :retention
      get :events
      get :weekly_activity
    end
  end

  namespace :api, path: '/api/v1', defaults: {format: :json} do
    resources :groups, only: [:show, :create, :update] do
      get :subgroups, on: :member
      patch :archive, on: :member
    end
    resources :memberships, only: [:index, :create, :update, :destroy] do
      get :autocomplete, on: :collection
      get :my_memberships, on: :collection
      patch :make_admin, on: :member
      patch :remove_admin, on: :member
    end
    resources :invitables, only: :index
    resources :invitations, only: :create
    resources :events, only: :index

    resources :discussions, only: [:show, :index, :create, :update, :destroy] do
      get :inbox, on: :collection
      patch :mark_as_read, on: :member
    end

    resources :motions,     only: [       :index, :create, :update], path: :proposals do
      post :close, on: :member
    end
    resources :votes,       only: [       :index, :create, :update] do
      get :my_votes, on: :collection
    end
    resources :comments,    only: [:create, :update, :destroy] do
      post :like, on: :member
      post :unlike, on: :member
    end
    resources :attachments, only: [:create, :destroy]
    resources :motions, only: :create do
      post :vote, on: :member
    end
    resources :translations, only: :show
    resources :notifications, only: :index
    resources :search_results, only: :index
    resources :contact_messages, only: :create
    namespace :faye do
      post :subscribe
      get :who_am_i
    end
    namespace :sessions do
      get :current
      get :unauthorized
    end
    devise_scope :user do
      resources :sessions, only: [:create, :destroy]
    end
    get '/attachments/credentials',      to: 'attachments#credentials'
    get  '/contacts/import',             to: 'contacts#import'
    get  '/contacts/:importer/callback', to: 'contacts#callback'
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
    put 'update_preferences'
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
      post :follow
      post :unfollow
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

  scope module: :groups do
    resources :manage_membership_requests, only: [], as: 'membership_requests' do
      member do
        post :approve
        post :ignore
      end
    end
  end

  scope module: :groups, path: 'g', slug: slug_regex do
    get    ':id(/:slug)', action: 'show' #, as: :group
    patch    ':id(/:slug)', action: 'update'
    delete ':id(/:slug)', action: 'destroy'
    post 'archive/:id',  action: 'archive', as: :archive_group
  end

  constraints(GroupSubdomainConstraint) do
    get '/' => 'groups#show'
    patch '/' => 'groups#update'
  end

  constraints(MainDomainConstraint) do
    root :to => 'marketing#index'
  end

  delete 'membership_requests/:id/cancel', to: 'groups/membership_requests#cancel', as: :cancel_membership_request

  resources :motions, path: 'm', only: [:new, :create, :edit, :index] do
    resources :votes, only: [:new, :create, :update]
    member do
      get :history
      patch :close
      patch :create_outcome
      patch :update_outcome
    end
  end

  scope module: :motions, path: 'm', slug: slug_regex do
    get    ':id(/:slug)', action: 'show', as: :motion
    patch  ':id(/:slug)', action: 'update'
    delete ':id(/:slug)', action: 'destroy'
  end

  get '/localisation/datetime_input_translations' => 'localisation#datetime_input_translations', format: 'js'

  resources :discussions, path: 'd', only: [:new, :edit, :create] do
    get :activity_counts, on: :collection
    resources :invitations, only: [:new]

    member do
      post :follow
      post :unfollow
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

  get '/localisation/:locale' => 'localisation#show', format: 'js'

  resources :users, path: 'u', only: [:new] do
    member do
      put :set_avatar_kind
      post :upload_new_avatar
      post :dismiss_system_notice
    end
  end

  namespace :email_actions do
    get   'unfollow_discussion/:discussion_id/:unsubscribe_token', action: 'unfollow_discussion', as: :unfollow_discussion
    get   'mark_summary_email_as_read', action: 'mark_summary_email_as_read', as: :mark_summary_email_as_read
    get   'mark_discussion_as_read/:discussion_id/:event_id/:unsubscribe_token', action: 'mark_discussion_as_read', as: :mark_discussion_as_read
  end

  scope module: :users do
    match '/profile',          action: 'profile', as: :profile, via: [:get, :post]
    get 'import_contacts' => 'contacts#import'
    get 'autocomplete_contacts' => 'contacts#autocomplete'

    scope module: :email_preferences do
      get   '/email_preferences', action: 'edit',   as: :email_preferences
      put   '/email_preferences', action: 'update', as: :update_email_preferences
    end

    scope module: :change_password do
      get '/change_password', action: 'show'
      post '/change_password', action: 'update'
    end

    scope module: :user_deactivation_responses do
      post '/user_deactivation_responses', action: 'create'
    end
  end

  scope module: :users, path: 'u' do
    get ':id(/:slug)', action: 'show',    slug: slug_regex, as: :user
    patch ':id(/:slug)', action: 'update',  slug: slug_regex
    post ':id(/:slug)', action: 'deactivate', slug: slug_regex
  end

  get '/deactivation_instructions' => 'users#deactivation_instructions'
  get '/about_deactivation' => 'users#about_deactivation'

  post '/translate/:model/:id', to: 'translations#create', as: :translate

  get '/users/invitation/accept' => redirect {|params, request|  "/invitations/#{request.query_string.gsub('invitation_token=','')}"}
  get '/group_requests/:id/start_new_group' => redirect {|params, request|  "/invitations/#{request.query_string.gsub('token=','')}"}

  get '/contributions' => redirect('/crowd')
  get '/contributions/thanks' => redirect('/crowd')
  get '/contributions/callback' => redirect('/crowd')
  get '/crowd' => redirect('https://love.loomio.org/')
  get '/groups' => redirect('/explore')

  get '/dashboard', to: 'dashboard#show', as: 'dashboard'

  constraints(MainDomainConstraint) do
    scope controller: 'pages' do
      get :about
      get :privacy
      get :purpose
      get :services
      get :terms_of_service
      get :third_parties
      get :try_it
      get :translation
      get :wallets
      get :browser_not_supported
      get :crowdfunding_celebration
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
  get '/community'  => redirect('https://www.loomio.org/g/WmPCB3IR/loomio-community')
  get '/timeline'   => redirect('http://www.tiki-toki.com/timeline/entry/313361/Loomio')

  get '/robots'     => 'robots#show'
end
