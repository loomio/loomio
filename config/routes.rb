Loomio::Application.routes.draw do

  use_doorkeeper

  get '/development' => 'development#index'
  namespace :development do
    get ':action'
  end

  scope '/angular', controller: 'angular', path: 'angular', as: 'angular' do
    get '/' => 'angular#index'
    post :on
    post :off
  end

  slug_regex = /[a-z0-9\-\_]*/i

  namespace :admin do
    get 'url_info' => 'base#url_info'
    namespace :stats do
      get :bad_analytics
      get :group_activity
      get :daily_activity
      get :first_30_days
      get :retention
      get :events
      get :weekly_activity
      get :cohorts
      get :aaarrr
    end
  end

  ActiveAdmin.routes(self)

  namespace :popolo, path: '/api/popolo', defaults: {format: :json} do
    resources :motions, only: :index
  end

  namespace :api, path: '/api/v1', defaults: {format: :json} do

    resources :groups, only: [:index, :show, :create, :update] do
      get :subgroups, on: :member
      patch :archive, on: :member
      put :archive, on: :member
      post :use_gift_subscription, on: :member
      post 'upload_photo/:kind', on: :member, action: :upload_photo
    end

    resources :users, only: :show

    resources :memberships, only: [:index, :create, :update, :destroy] do
      collection do
        post :add_to_subgroup
        post :join_group
        get :autocomplete
        get :for_user
        get :my_memberships
        get :invitables
      end
      member do
        post :make_admin
        post :remove_admin
        patch :set_volume
      end
    end

    resources :membership_requests, only: [:create] do
      collection do
        get :my_pending
        get :pending
        get :previous
      end
      post :approve, on: :member
      post :ignore, on: :member
    end

    resources :invitations, only: [:create, :destroy] do
      get :pending, on: :collection
      get :shareable, on: :collection
    end

    resources :profile, only: [:show] do
      post :update_profile, on: :collection
      post :set_volume, on: :collection
      post :upload_avatar, on: :collection
      post :change_password, on: :collection
      post :deactivate, on: :collection
    end

    resources :events, only: :index
    resources :drafts do
      collection do
        get    '/:draftable_type/:draftable_id', action: :show
        post   '/:draftable_type/:draftable_id', action: :update
        patch  '/:draftable_type/:draftable_id', action: :update
        put    '/:draftable_type/:draftable_id', action: :update
      end
    end

    resources :discussions, only: [:show, :index, :create, :update, :destroy] do
      patch :mark_as_read, on: :member
      patch :set_volume, on: :member
      patch :star, on: :member
      patch :unstar, on: :member
      patch :move, on: :member
      put :mark_as_read, on: :member
      put :set_volume, on: :member
      put :star, on: :member
      put :unstar, on: :member
      put :move, on: :member
      get :dashboard, on: :collection
      get :inbox, on: :collection
    end

    resources :search, only: :index

    resources :motions,     only: [:show, :index, :create, :update], path: :proposals do
      post :close, on: :member
      post :create_outcome, on: :member
      post :update_outcome, on: :member
      get  :closed, on: :collection
    end

    resources :votes,       only: [       :index, :create, :update] do
      get :my_votes, on: :collection
    end

    resources :did_not_votes, only: :index

    resources :comments,    only: [:create, :update, :destroy] do
      post :like, on: :member
      post :unlike, on: :member
    end

    resources :attachments, only: [:create, :destroy]

    resources :motions, only: :create do
      post :vote, on: :member
    end

    resource :translations, only: :show do
      get :inline, to: 'translations#inline'
    end

    resources :notifications, only: :index do
      post :viewed, on: :collection
    end

    resources :contacts, only: :index do
      get :import, on: :collection
    end

    resources :contact_messages, only: :create

    resources :versions, only: :index

    resources :oauth_applications, only: [:show, :create, :update, :destroy] do
      post :revoke_access, on: :member
      post :upload_logo, on: :member
      get :owned, on: :collection
      get :authorized, on: :collection
    end

    namespace :message_channel do
      post :subscribe
    end

    namespace :sessions do
      get :current
      get :unauthorized
    end
    devise_scope :user do
      resource :sessions, only: [:create, :destroy]
    end
    get '/attachments/credentials',      to: 'attachments#credentials'
    get  '/contacts/:importer/callback', to: 'contacts#callback'
  end

  constraints(GroupSubdomainConstraint) do
    get '/' => 'redirect#group_subdomain'
    get '/d/:id(/:slug)', to: 'redirect#discussion_key'
    get '/g/:id(/:slug)', to: 'redirect#group_key'
    get '/m/:id(/:slug)', to: 'redirect#motion_key'
  end

  constraints(MainDomainConstraint) do
    root :to => 'root#index'
  end

  get "/browser_not_supported", to: "application#browser_not_supported"

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

  namespace :subscriptions do
    post :webhook
  end

  resources :invitations, only: [:show, :create, :destroy]

  get "/theme_assets/:id", to: 'theme_assets#show', as: 'theme_assets'


  resources :networks, path: 'n', only: [:show] do
    member do
      get :groups
    end
    resources :network_membership_requests, path: 'membership_requests', as: 'membership_requests', only: [:create, :new, :index] do
      member do
        post :approve
        post :decline
      end
    end
  end

  get 'start_group' => 'start_group#new'
  post 'start_group' => 'start_group#create'
  post 'enable_angular' => 'start_group#enable_angular'

  resources :groups, path: 'g', only: [:create, :edit, :update] do
    member do
      get :export
      post :set_volume
      post :join
      post :add_members
      post :hide_next_steps
      get :add_subgroup
      post :email_members
      post :edit_description
      delete :leave_group
      get :members_autocomplete
      get :previous_proposals, action: :show
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
    get    ':id(/:slug)', action: 'show'
    patch    ':id(/:slug)', action: 'update'
    delete ':id(/:slug)', action: 'destroy'
    post 'archive/:id',  action: 'archive', as: :archive_group
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
      post :set_volume
      post :update_description
      post :update
      post :add_comment
      post :show_description_history
      get :new_proposal
      post :move
      get :print
    end
  end

  scope module: :discussions, path: 'd', slug: slug_regex do
    get    ':id(/:slug)', action: 'show'
    patch  ':id(/:slug)', action: 'update'
    delete ':id(/:slug)', action: 'destroy'

    post ':id/preview_version/(:version_id)', action: 'preview_version', as: 'preview_version_discussion'
    post 'update_version/:version_id',        action: 'update_version',   as: 'update_version_discussion'
  end

  resources :comments , only: [:destroy, :edit, :update, :show] do
    post :like, on: :member
    post :unlike, on: :member
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

  resources :users, path: 'u', only: [] do
    member do
      put :set_avatar_kind
      post :upload_new_avatar
      post :dismiss_system_notice
    end
  end

  namespace :email_actions do
    get   'unfollow_discussion/:discussion_id/:unsubscribe_token', action: 'unfollow_discussion', as: :unfollow_discussion
    get   'follow_discussion/:discussion_id/:unsubscribe_token',   action: 'follow_discussion',   as: :follow_discussion
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

  scope module: :users, path: 'u', slug: slug_regex do
    get ':id(/:slug)', action: 'show', as: :user
    patch ':id(/:slug)', action: 'update'
    post ':id(/:slug)', action: 'deactivate'
  end

  get '/deactivation_instructions' => 'users#deactivation_instructions'
  get '/about_deactivation' => 'users#about_deactivation'

  post '/translate/:model/:id', to: 'translations#create', as: :translate

  get '/users/invitation/accept' => redirect {|params, request|  "/invitations/#{request.query_string.gsub('invitation_token=','')}"}

  get '/dashboard', to: 'dashboard#show', as: 'dashboard'

  # this is a dumb thing
  get '/groups', to: 'dashboard#show'

  post '/email_processor' => 'griddler/emails#create', format: :json
  get "/email_processor", to: proc { [200, {}, ["OK"]] }, as: "head_test_request"

  constraints(MainDomainConstraint) do
    scope controller: 'pages' do
      get :browser_not_supported
    end
  end

  scope controller: 'help' do
    get :help
    get :markdown
  end

  resources :contact_messages, only: [:new, :create]
  get 'contact(/:destination)', to: 'contact_messages#new'


  get '/discussions/:id', to: 'redirect#discussion_id'
  get '/groups/:id',      to: 'redirect#group_id'
  get '/motions/:id',     to: 'redirect#motion_id'

  scope path: 'pages' do
    match 'contact'    => 'contact_messages#new', via: [:get, :post]
  end

  get '/robots'     => 'robots#show'

  get 'apps/registered'                    => 'application#boot_angular_ui'
  get 'apps/authorized'                    => 'application#boot_angular_ui'
  get 'apps/registered/:id'                => 'application#boot_angular_ui'
  get 'apps/registered/:id/:slug'          => 'application#boot_angular_ui'
  get 'd/:key/proposal/:proposal'          => 'application#boot_angular_ui'
  get 'd/:key/comment/:comment'            => 'application#boot_angular_ui'
  get 'd/:key/proposal/:proposal/:outcome' => 'application#boot_angular_ui'
  get 'g/:key/memberships/:username'       => 'application#boot_angular_ui'
  get 'explore'                            => 'application#boot_angular_ui', as: :explore

  get '/donate', to: redirect('https://loomio-donation.chargify.com/subscribe/9wnjv4g2cc9t/donation')

end
