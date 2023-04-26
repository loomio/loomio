def dev_routes_for(namespace)
  controller = "Dev::#{namespace.to_s.humanize}Controller".constantize.new
  methods = controller.public_methods - Dev::BaseController.new.public_methods

  namespace namespace do
    get '/' => :index
    methods.map { |action| get action }
  end
end

require 'sidekiq/web'

Rails.application.routes.draw do
  get "/up", to: proc { [200, {}, ["ok"]] }, as: :rails_health_check
  
  authenticate :user, lambda { |u| u.is_admin? } do
    mount Sidekiq::Web => '/admin/sidekiq'
    mount Blazer::Engine, at: "/admin/blazer"
    # mount PgHero::Engine, at: "/admin/pghero"
  end

  if !Rails.env.production?
    namespace :dev do
      dev_routes_for(:discussions)
      dev_routes_for(:polls)
      dev_routes_for(:nightwatch)

      get '/', to: 'nightwatch#index'
      get '/:action', to: 'nightwatch#:action'
    end
  end

  get '/discussions/:id', to: 'redirect#discussion'
  get '/groups/:id',      to: 'redirect#group'

  root to: 'root#index'

  ActiveAdmin.routes(self)

  namespace :api, defaults: {format: :json} do
    namespace :b1 do
      resources :discussions, only: [:create, :show]
      resources :polls, only: [:create, :show]
      resources :memberships, only: [:index, :create]
    end

    namespace :v1 do
      resources :attachments, only: [:index, :destroy]
      resources :webhooks, only: [:create, :destroy, :index, :update]
      resources :chatbots, only: [:create, :destroy, :index, :update] do
        post :test, on: :collection
      end

      resources :boot, only: [] do
        get :site, on: :collection
        get :user, on: :collection
        get :version, on: :collection
      end

      resources :demos, only: [:index] do
        post :clone, on: :collection
      end

      resources :link_previews, only: [:create]

      resources :tasks, only: [:index] do
        collection do
          post :update_done
        end

        member do
          post :mark_as_done
          post :mark_as_not_done
        end
      end

      resources :groups, only: [:index, :show, :create, :update, :destroy] do
        member do
          get :token
          post :reset_token
          get :subgroups
          post :export
          post 'upload_photo/:kind', action: :upload_photo
        end
        collection do
          get :count_explore_results
          get :suggest_handle
        end
      end

      resources :memberships, only: [:index, :create, :update, :destroy] do
        collection do
          post :join_group
          get :for_user
          get :autocomplete, action: :index
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

      resources :profile, only: [:show, :index] do
        collection do
          get  :time_zones
          get  :mentionable_users
          get  :me
          get  :groups
          get  :email_status
          get  :email_exists
          get  :send_merge_verification_email
          get  :contactable
          get  :avatar_uploaded
          get  :email_api_key
          post :send_email_to_group_address
          post :reset_email_api_key
          post :update_profile
          post :set_volume
          post :upload_avatar
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
        get :position_keys, on: :collection
        get :timeline, on: :collection
        patch :remove_from_thread, on: :member
      end

      resources :discussions, only: [:show, :index, :create, :update] do
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
        delete :discard, on: :member
        post  :fork, on: :collection
        patch :move_comments, on: :member
        get :history, on: :member
        get :search, on: :collection
        get :dashboard, on: :collection
        get :inbox, on: :collection
        get :direct, on: :collection
      end

      resources :discussion_readers, only: [:index] do
        member do
          post :remove_admin
          post :make_admin
          post :resend
          post :revoke
        end
      end

      resources :tags, only: [:create, :update, :destroy] do
        collection do
          post :priority
        end
      end

      resources :search, only: :index

      resources :polls, only: [:show, :index, :create, :update] do
        member do
          post :remind
          delete :discard
          post :close
          post :reopen
          post :add_options
          patch :add_to_thread
        end
        get  :closed, on: :collection
      end

      resource :outcomes,     only: [:create, :update]

      resources :stances, only: [:index, :create, :update] do
        member do
          patch :uncast
        end

        collection do
          get :invite
          get :users
          get :my_stances
          post :make_admin
          post :remove_admin
          post :revoke
        end
      end

      resources :outcomes,    only: [:create, :update]

      resources :comments,    only: [:create, :update, :destroy] do
        delete :discard, on: :member
        post :undiscard, on: :member
      end
      resources :reactions,   only: [:create, :update, :index, :destroy]

      resources :documents, only: [:create, :update, :destroy, :index] do
        get :for_group, on: :collection
        get :for_discussion, on: :collection
      end

      resource :translations, only: [] do
        get :inline, to: 'translations#inline'
      end

      resources :notifications, only: :index do
        post :viewed, on: :collection
      end

      resources :announcements, only: [:create] do
        collection do
          get :audience
          get :count
          get :search
          get :history
          get :users_notified_count
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
  end

  post '/direct_uploads', to: 'direct_uploads#create'

  get '/users/sign_in', to: redirect('/dashboard')
  get '/users/sign_up', to: redirect('/dashboard')
  devise_for :users

  resources :contact_messages, only: [:new, :create] do
    get :show, on: :collection
  end

  post :email_processor, to: 'received_emails#create'

  namespace :email_actions do
    get 'unfollow_discussion/:discussion_id/:unsubscribe_token', action: 'unfollow_discussion', as: :unfollow_discussion
    get 'mark_summary_email_as_read', action: 'mark_summary_email_as_read', as: :mark_summary_email_as_read
    get 'mark_discussion_as_read/:discussion_id/:event_id/:unsubscribe_token', action: 'mark_discussion_as_read', as: :mark_discussion_as_read
  end

  post '/bug_tunnel' => 'application#bug_tunnel'

  get '/robots'     => 'robots#show'
  get '/manifest'   => 'manifest#show', format: :json
  get '/help/api'   => 'help#api'

  get '/start_group', to: redirect('/try')

  get 'try'                                => 'application#index'
  get 'dashboard'                          => 'application#index', as: :dashboard
  get 'dashboard/:filter'                  => 'application#index'
  get 'inbox'                              => 'application#index', as: :inbox
  get 'groups'                             => 'application#index', as: :groups
  get 'polls'                              => 'application#index', as: :polls
  get 'explore'                            => 'groups#index',      as: :explore
  get 'profile'                            => 'application#index', as: :profile
  get 'contact'                            => 'application#index', as: :contact
  get 'email_preferences'                  => 'application#index', as: :email_preferences
  get 'apps/registered'                    => 'application#index'
  get 'apps/authorized'                    => 'application#index'
  get 'apps/registered/:id'                => 'application#index'
  get 'apps/registered/:id/:slug'          => 'application#index'
  get 'g/:key/membership_requests'         => 'application#index', as: :group_membership_requests
  get 'g/:key/members/requests'            => 'application#index', as: :group_members_requests
  get 'g/:key/memberships'                 => 'application#index', as: :group_memberships
  get 'g/:key/settings'                    => 'application#index', as: :group_settings
  get 'g/:key/previous_polls'              => 'application#index', as: :group_previous_polls
  get 'g/:key/memberships/:username'       => 'application#index', as: :group_memberships_username
  get 'g/:key/tags(/:tag_name)'            => 'application#index', as: :group_tags
  get 'g/new'                              => 'application#index', as: :new_group
  get 'd/new'                              => 'application#index', as: :new_discussion
  get 'p/new(/:type)'                      => 'application#index', as: :new_poll
  get 'threads/direct'                     => 'application#index', as: :groupless_threads
  get 'tasks'                              => 'application#index', as: :tasks

  get 'g/:key/export'                      => 'groups#export',               as: :group_export
  get 'g/:key/stats'                       => 'groups#stats',                as: :group_stats
  get 'p/:key/export'                      => 'polls#export',                as: :poll_export
  get 'd/:key/export'                      => 'discussions#export',          as: :discussion_export
  get 'g/:key(/:slug)'                     => 'groups#show',                 as: :group
  get 'd/:key(/:slug)(/:sequence_id)'      => 'discussions#show',            as: :discussion
  get 'd/:key/comment/:comment_id'         => 'discussions#show',            as: :comment
  get 'p/:key/unsubscribe'                 => 'polls#unsubscribe',           as: :poll_unsubscribe
  get 'p/:key(/:slug)'                     => 'polls#show',                  as: :poll
  get 'vote/:key(/:slug)'                  => 'polls#show'
  get 'u/undefined'                        => redirect('404.html')
  get 'u/anonymous'                        => redirect('404.html')
  get 'u/:username/'                       => 'users#show',                  as: :user

  get '/login_tokens/:token'               => 'login_tokens#show',           as: :login_token
  get '/invitations/:token'                => 'memberships#show',            as: :membership
  get '/join/:model/:token'                => 'memberships#join',            as: :join
  get '/invitations/consume'               => 'memberships#consume'

  get '/donate'                            => redirect('410.html')
  get '/users/invitation/accept'           => redirect('410.html')
  get '/notifications/dropdown_items'      => redirect('410.html')
  get '/u/:key(/:stub)'                    => redirect('410.html')
  get '/g/:key/membership_requests/new'    => redirect('410.html')
  get '/comments/:id'                      => redirect('410.html')

  get '/merge_users/confirm' => 'merge_users#confirm'
  post '/merge_users/merge' => 'merge_users#merge'

  # for IE / other browsers which insist on requesting things which don't exist
  get '/favicon.ico'                       => 'application#ok'
  get '/wp-login.php'                      => 'application#ok'
  get '/crowdfunding_celebration'          => 'application#crowdfunding'
  get '/crowdfunding'                      => 'application#crowdfunding'
  get '/brand'                             => 'application#brand'
  get '/sitemap.xml' => 'application#sitemap'


  Identities::Base::PROVIDERS.each do |provider|
    scope provider do
      get :oauth,                           to: "identities/#{provider}#oauth",       as: :"#{provider}_oauth"
      get :authorize,                       to: "identities/#{provider}#create",      as: :"#{provider}_authorize"
      get '/',                              to: "identities/#{provider}#destroy",     as: :"#{provider}_unauthorize"
    end
  end

  scope :saml do
    post :oauth,                          to: 'identities/saml#create',   as: :saml_oauth_callback
    get :metadata,                        to: 'identities/saml#metadata', as: :saml_metadata
  end

  mount LoomioSubs::Engine, at: "/" if Object.const_defined?('LoomioSubs')

  get ":id", to: 'groups#show', as: :group_handle
end
