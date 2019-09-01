Loomio::Application.routes.draw do
  if !Rails.env.production?
    namespace :dev do
      namespace :discussions do
        get '/' => :index
        get ':action'
      end

      namespace :polls do
        get '/' => :index
        get ':action'
      end

      namespace :nightwatch do
        get '/' => :index
        get ':action'
      end

      get '/', to: 'nightwatch#index'
      get '/:action', to: 'nightwatch#:action'
    end
  end

  mount ActionCable.server => '/cable'

  use_doorkeeper do
    skip_controllers :applications, :authorized_applications
  end

  constraints(GroupSubdomainConstraints) do
    get '/',              to: 'redirect#subdomain'
    get '/d/:id(/:slug)', to: 'redirect#discussion'
    get '/g/:id(/:slug)', to: 'redirect#group'
    get '/p/:id(/:slug)', to: 'redirect#poll'
  end
  get '/discussions/:id', to: 'redirect#discussion'
  get '/groups/:id',      to: 'redirect#group'

  root to: 'root#index'

  get '/personal_data', to: 'personal_data#index'
  get '/personal_data/:table', to: 'personal_data#show'


  ActiveAdmin.routes(self)

  namespace :api, path: '/api/v1', defaults: {format: :json} do
    resources :attachments, only: :index

    resources :boot, only: [] do
      get :site, on: :collection
      get :user, on: :collection
    end

    resources :usage_reports, only: [:create]

    resources :groups, only: [:index, :show, :create, :update] do
      member do
        get :token
        post :reset_token
        get :subgroups
        post :export
        patch :archive
        put :archive
        post 'upload_photo/:kind', action: :upload_photo
      end
      get :count_explore_results, on: :collection
    end

    resources :group_identities, only: [:create, :destroy]

    resources :memberships, only: [:index, :create, :update, :destroy] do
      collection do
        post :add_to_subgroup
        post :join_group
        get :autocomplete
        get :for_user
        get :my_memberships
        get :invitables
        get :undecided
      end
      member do
        post :make_admin
        post :remove_admin
        post :save_experience
        post :resend
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

    resources :profile, only: [:show] do
      collection do
        get  :time_zones
        get  :mentionable_users
        get  :me
        get  :email_status
        post :update_profile
        post :set_volume
        post :upload_avatar
        post :deactivate
        post :reactivate
        post :save_experience
        delete :destroy
      end
      post :remind, on: :member
    end

    resources :login_tokens, only: [:create]

    resources :events, only: :index do
      patch :pin, on: :member
      patch :unpin, on: :member
      get :comment, on: :collection
      patch :remove_from_thread, on: :member
    end

    resources :drafts do
      collection do
        get    '/:draftable_type/:draftable_id', action: :show
        post   '/:draftable_type/:draftable_id', action: :update
        patch  '/:draftable_type/:draftable_id', action: :update
        put    '/:draftable_type/:draftable_id', action: :update
      end
    end

    resources :discussions, only: [:show, :index, :create, :update, :destroy] do
      patch :mark_as_seen, on: :member
      patch :dismiss, on: :member
      patch :recall, on: :member
      patch :set_volume, on: :member
      patch :pin, on: :member
      patch :unpin, on: :member
      patch :pin_reader, on: :member
      patch :unpin_reader, on: :member
      patch :move, on: :member
      patch :mark_as_read, on: :member
      patch :set_volume, on: :member
      patch :pin, on: :member
      patch :close, on: :member
      patch :reopen, on: :member
      patch :unpin, on: :member
      patch :pin_reader, on: :member
      patch :unpin_reader, on: :member
      patch :move, on: :member
      post  :fork, on: :collection
      get :search, on: :collection
      get :dashboard, on: :collection
      get :inbox, on: :collection
      get '/tags/:id/(:stub)', action: :tags, on: :collection
    end

    resources :discussion_tags, only: [:create, :destroy]

    resources :tags do
      collection do
        post :update_model
      end
    end


    resources :search, only: :index

    resources :polls,       only: [:show, :index, :create, :update, :destroy] do
      post :close, on: :member
      post :reopen, on: :member
      post :add_options, on: :member
      post :toggle_subscription, on: :member
      get  :closed, on: :collection
      get  :search, on: :collection
      get  :search_results_count, on: :collection
    end

    resource :outcomes,     only: [:create, :update]

    resources :stances,     only: [:index, :create, :update, :destroy] do
      get :my_stances, on: :collection
    end

    resources :outcomes,    only: [:create, :update]

    resources :poll_did_not_votes, only: :index

    resources :comments,    only: [:create, :update, :destroy]
    resources :reactions,   only: [:create, :update, :index, :destroy]

    resources :documents, only: [:create, :update, :destroy, :index] do
      get :for_group, on: :collection
      get :for_discussion, on: :collection
    end

    resource :translations, only: [] do
      get :show, on: :collection
      get :inline, to: 'translations#inline'
    end

    resources :notifications, only: :index do
      post :viewed, on: :collection
    end

    resources :announcements, only: [:create] do
      collection do
        get :audience
        get :search
        get :history
        get :preview
      end
    end

    resources :contact_messages, only: :create
    resources :contact_requests, only: :create

    resources :versions, only: [] do
      get :show, on: :collection
    end

    resources :oauth_applications, only: [:show, :create, :update, :destroy] do
      post :revoke_access, on: :member
      post :upload_logo, on: :member
      get :owned, on: :collection
      get :authorized, on: :collection
    end

    namespace(:sessions)        { get :unauthorized }
    devise_scope :user do
      resource :sessions, only: [:create, :destroy]
      resource :registrations, only: :create do
        post :oauth, on: :collection
      end
    end
    get "identities/:id/:command", to: "identities#command"
  end

  get '/tags/:id/(:stub)', to: 'application#index'
  post '/direct_uploads', to: 'direct_uploads#create'

  get '/users/sign_in', to: redirect('/dashboard')
  get '/users/sign_up', to: redirect('/dashboard')
  devise_for :users

  namespace(:subscriptions) do
    post :webhook
  end

  resources :received_emails, only: :create
  post :email_processor, to: 'received_emails#reply'

  namespace :email_actions do
    get 'unfollow_discussion/:discussion_id/:unsubscribe_token', action: 'unfollow_discussion', as: :unfollow_discussion
    get 'mark_summary_email_as_read', action: 'mark_summary_email_as_read', as: :mark_summary_email_as_read
    get 'mark_discussion_as_read/:discussion_id/:event_id/:unsubscribe_token', action: 'mark_discussion_as_read', as: :mark_discussion_as_read
  end


  get '/robots'     => 'robots#show'
  get '/manifest'   => 'manifest#show', format: :json
  get '/markdown'   => 'help#markdown'

  get '/start_group', to: redirect('/g/new')

  get 'dashboard'                          => 'application#index', as: :dashboard
  get 'dashboard/:filter'                  => 'application#index'
  get 'inbox'                              => 'application#index', as: :inbox
  get 'groups'                             => 'application#index', as: :groups
  get 'polls'                              => 'application#index', as: :polls
  get 'explore'                            => 'application#index', as: :explore
  get 'profile'                            => 'application#index', as: :profile
  get 'contact'                            => 'application#index', as: :contact
  get 'email_preferences'                  => 'application#index', as: :email_preferences
  get 'apps/registered'                    => 'application#index'
  get 'apps/authorized'                    => 'application#index'
  get 'apps/registered/:id'                => 'application#index'
  get 'apps/registered/:id/:slug'          => 'application#index'
  get 'd/:key/comment/:comment'            => 'application#index', as: :discussion_comment
  get 'g/:key/membership_requests'         => 'application#index', as: :group_membership_requests
  get 'g/:key/members/requests'            => 'application#index', as: :group_members_requests
  get 'g/:key/memberships'                 => 'application#index', as: :group_memberships
  get 'g/:key/settings'                    => 'application#index', as: :group_settings
  get 'g/:key/previous_polls'              => 'application#index', as: :group_previous_polls
  get 'g/:key/memberships/:username'       => 'application#index', as: :group_memberships_username
  get 'g/new'                              => 'application#index', as: :new_group
  get 'd/new'                              => 'application#index', as: :new_discussion
  get 'p/new(/:type)'                      => 'application#index', as: :new_poll

  get 'g/:key/export'                      => 'groups#export',               as: :group_export
  get 'p/:key/export'                      => 'polls#export',                as: :poll_export
  get 'g/:key(/:slug)'                     => 'groups#show',                 as: :group
  get 'd/:key(/:slug)(/:sequence_id)'      => 'discussions#show',            as: :discussion
  get 'd/:key/comment/:comment_id'         => 'discussions#show',            as: :comment
  get 'p/:key/unsubscribe'                 => 'polls#unsubscribe',           as: :poll_unsubscribe
  get 'p/:key(/:slug)'                     => 'polls#show',                  as: :poll
  get 'vote/:key(/:slug)'                  => 'polls#show'
  get 'u/undefined'                        => redirect('404.html')
  get 'u/:username/'                       => 'users#show',                  as: :user

  get '/login_tokens/:token'               => 'login_tokens#show',           as: :login_token
  get '/invitations/:token'                => 'memberships#show',            as: :membership
  get '/join/:model/:token'                => 'memberships#join',            as: :join

  get '/donate'                            => redirect('410.html')
  get '/users/invitation/accept'           => redirect('410.html')
  get '/notifications/dropdown_items'      => redirect('410.html')
  get '/u/:key(/:stub)'                    => redirect('410.html')
  get '/g/:key/membership_requests/new'    => redirect('410.html')
  get '/comments/:id'                      => redirect('410.html')


  # for IE / other browsers which insist on requesting things which don't exist
  get '/favicon.ico'                       => 'application#ok'
  get '/wp-login.php'                      => 'application#ok'
  get '/crowdfunding_celebration'          => 'application#crowdfunding'


  Identities::Base::PROVIDERS.each do |provider|
    scope provider do
      get :oauth,                           to: "identities/#{provider}#oauth",       as: :"#{provider}_oauth"
      get :authorize,                       to: "identities/#{provider}#create",      as: :"#{provider}_authorize"
      get '/',                              to: "identities/#{provider}#destroy",     as: :"#{provider}_unauthorize"
    end
  end

  scope :facebook do
    get :webhook,                         to: 'identities/facebook#verify',   as: :facebook_verify
    post :webhook,                        to: 'identities/facebook#webhook',  as: :facebook_webhook
    get :webview,                         to: 'identities/facebook#webview',  as: :facebook_webview
  end

  scope :slack do
    get  :install,                        to: 'identities/slack#install',     as: :slack_install
    get  :authorized,                     to: 'identities/slack#authorized',  as: :slack_authorized
    post :participate,                    to: 'identities/slack#participate', as: :slack_participate
    post :initiate,                       to: 'identities/slack#initiate',    as: :slack_initiate
  end

  scope :saml do
    post :oauth,                          to: 'identities/saml#create',   as: :saml_oauth_callback
    get :metadata,                        to: 'identities/saml#metadata', as: :saml_metadata
  end

  get '/beta' => 'beta#index'
  put '/beta' => 'beta#update'

  get ":id", to: 'groups#show', as: :group_handle, format: :html
end
