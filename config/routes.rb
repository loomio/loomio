Loomio::Application.routes.draw do

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

  namespace :dev do
    namespace :discussions do
      get '/' => :index
      get ':action'
    end

    namespace :polls do
      get '/' => :index
      get ':action'
    end

    scope controller: 'main' do
      get '/' => :index
      get ':action'
      get 'last_email'
    end
  end

  ActiveAdmin.routes(self)

  namespace :api, path: '/api/v1', defaults: {format: :json} do
    resources :usage_reports, only: [:create]

    resources :groups, only: [:index, :show, :create, :update] do
      get :subgroups, on: :member
      get :count_explore_results, on: :collection
      patch :archive, on: :member
      put :archive, on: :member
      post 'upload_photo/:kind', on: :member, action: :upload_photo
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

    resources :invitations, only: [:index, :create, :destroy] do
      post :bulk_create, on: :collection
      post :resend, on: :member
      get :pending, on: :collection
      get :shareable, on: :collection
    end

    resources :profile, only: [:show] do
      get  :me, on: :collection
      get  :email_status, on: :collection
      post :remind, on: :member
      post :update_profile, on: :collection
      post :set_volume, on: :collection
      post :upload_avatar, on: :collection
      post :deactivate, on: :collection
      post :save_experience, on: :collection
    end

    resources :login_tokens, only: [:create]

    resources :events, only: :index do
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
      get :search, on: :collection
      get :dashboard, on: :collection
      get :inbox, on: :collection
    end

    resources :search, only: :index

    resources :polls,       only: [:show, :index, :create, :update, :destroy] do
      post :close, on: :member
      post :add_options, on: :member
      post :toggle_subscription, on: :member
      get  :closed, on: :collection
      get  :search, on: :collection
      get  :search_results_count, on: :collection
    end

    resource :outcomes,     only: [:create, :update]

    resources :stances,     only: [:index, :create, :update, :destroy] do
      get :unverified, on: :collection
      post :verify, on: :member
      get :my_stances, on: :collection
    end

    resources :outcomes,    only: [:create, :update]

    resources :poll_did_not_votes, only: :index

    resources :comments,    only: [:create, :update, :destroy]
    resources :reactions,   only: [:create, :update, :index, :destroy]

    resources :documents, only: [:create, :update, :destroy, :index] do
      get :for_group, on: :collection
    end

    resource :translations, only: [] do
      get :show, on: :collection
      get :inline, to: 'translations#inline'
    end

    resources :notifications, only: :index do
      post :viewed, on: :collection
    end

    resources :announcements, only: :create do
      get :notified, on: :collection
      get :notified_default, on: :collection
    end

    resources :contact_messages, only: :create
    resources :contact_requests, only: :create

    resources :versions, only: :index

    resources :oauth_applications, only: [:show, :create, :update, :destroy] do
      post :revoke_access, on: :member
      post :upload_logo, on: :member
      get :owned, on: :collection
      get :authorized, on: :collection
    end

    namespace(:message_channel) { post :subscribe }
    namespace(:sessions)        { get :unauthorized }
    devise_scope :user do
      resource :sessions, only: [:create, :destroy]
      resource :registrations, only: :create do
        post :oauth, on: :collection
      end
    end
    get "identities/:id/:command", to: "identities#command"
  end

  get '/users/sign_in', to: redirect('/dashboard')
  get '/users/sign_up', to: redirect('/dashboard')
  devise_for :users

  namespace(:subscriptions) do
    post :webhook
  end

  resources :invitations,     only: :show
  resources :login_tokens,    only: :show

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
  get 'verify_stances'                     => 'application#index', as: :verify_stances
  get 'apps/registered'                    => 'application#index'
  get 'apps/authorized'                    => 'application#index'
  get 'apps/registered/:id'                => 'application#index'
  get 'apps/registered/:id/:slug'          => 'application#index'
  get 'd/:key/comment/:comment'            => 'application#index', as: :discussion_comment
  get 'g/:key/membership_requests'         => 'application#index', as: :group_membership_requests
  get 'g/:key/memberships'                 => 'application#index', as: :group_memberships
  get 'g/:key/previous_polls'              => 'application#index', as: :group_previous_polls
  get 'g/:key/memberships/:username'       => 'application#index', as: :group_memberships_username
  get 'g/new'                              => 'application#index', as: :new_group
  get 'd/new'                              => 'application#index', as: :new_discussion
  get 'p/new(/:type)'                      => 'application#index', as: :new_poll
  get 'p/example(/:type)'                  => 'polls#example',               as: :example_poll

  get 'g/:key/export'                      => 'groups#export',               as: :group_export
  get 'g/:key(/:slug)'                     => 'groups#show',                 as: :group
  get 'd/:key(/:slug)(/:sequence_id)'      => 'discussions#show',            as: :discussion
  get 'd/:key/comment/:comment_id'         => 'discussions#show',            as: :comment
  get 'p/:key/unsubscribe'                 => 'polls#unsubscribe',           as: :poll_unsubscribe
  get 'p/:key(/:slug)'                     => 'polls#show',                  as: :poll
  get 'vote/:key(/:slug)'                  => 'polls#show'
  get 'u/undefined'                        => redirect('404.html')
  get 'u/:username/'                       => 'users#show',                  as: :user

  get '/donate'                            => redirect('410.html')
  get '/users/invitation/accept'           => redirect('410.html')
  get '/notifications/dropdown_items'      => redirect('410.html')
  get '/u/:key(/:stub)'                    => redirect('410.html')
  get '/g/:key/membership_requests/new'    => redirect('410.html')
  get '/comments/:id'                      => redirect('410.html')

  # for IE / other browsers which insist on requesting things which don't exist
  get '/favicon.ico'                       => 'application#ok'
  get '/wp-login.php'                      => 'application#ok'

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

  get ":id", to: 'groups#show', as: :group_handle
end
