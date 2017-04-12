Loomio::Application.routes.draw do

  use_doorkeeper do
    skip_controllers :applications, :authorized_applications
  end

  constraints(GroupSubdomainConstraints) do
    get '/' => 'redirect#group_subdomain'
    get '/d/:id(/:slug)', to: 'redirect#discussion_key'
    get '/g/:id(/:slug)', to: 'redirect#group_key'
    get '/m/:id(/:slug)', to: 'redirect#motion_key'
  end

  root to: 'root#index'

  namespace :dev do
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
      get :count_explore_results, on: :collection
      patch :archive, on: :member
      put :archive, on: :member
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

    resources :invitations, only: [:create, :destroy] do
      get :pending, on: :collection
      get :shareable, on: :collection
    end

    resources :profile, only: [:show] do
      get  :me, on: :collection
      post :update_profile, on: :collection
      post :set_volume, on: :collection
      post :upload_avatar, on: :collection
      post :change_password, on: :collection
      post :deactivate, on: :collection
      post :save_experience, on: :collection
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
      patch :dismiss, on: :member
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

    resources :polls,       only: [:show, :index, :create, :update] do
      post :close, on: :member
      get  :search, on: :collection
      get  :search_results_count, on: :collection
    end

    resources :visitors,    only: [:index, :create, :update, :destroy] do
      post :remind, on: :member
    end

    resource :outcomes,     only: [:create, :update]

    resources :votes,       only: [:index, :create, :update] do
      get :my_votes, on: :collection
    end

    resources :stances,     only: [:index, :create, :update] do
      get :my_stances, on: :collection
    end

    resources :outcomes,    only: [:create, :update]

    resources :did_not_votes, only: :index
    resources :poll_did_not_votes, only: :index

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

    resources :contact_messages, only: :create

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
      resource :registrations, only: :create
    end
  end

  get '/discussions/:id', to: 'redirect#discussion_id'
  get '/groups/:id',      to: 'redirect#group_id'
  get '/motions/:id',     to: 'redirect#motion_id'

  get "/browser_not_supported", to: "application#browser_not_supported"

  devise_for :users, controllers: { sessions: 'users/sessions',
                                    registrations: 'users/registrations',
                                    omniauth_callbacks: 'users/omniauth_callbacks' }

  namespace(:subscriptions) do
    get :select_gift_plan
    post :webhook
  end

  resources :invitations, only: [:show]
  get '/users/invitation/accept' => redirect {|params, request|  "/invitations/#{request.query_string.gsub('invitation_token=','')}"}

  namespace :email_actions do
    get   'unfollow_discussion/:discussion_id/:unsubscribe_token', action: 'unfollow_discussion', as: :unfollow_discussion
    get   'follow_discussion/:discussion_id/:unsubscribe_token',   action: 'follow_discussion',   as: :follow_discussion
    get   'mark_summary_email_as_read', action: 'mark_summary_email_as_read', as: :mark_summary_email_as_read
    get   'mark_discussion_as_read/:discussion_id/:event_id/:unsubscribe_token', action: 'mark_discussion_as_read', as: :mark_discussion_as_read
  end

  scope controller: 'help' do
    get :markdown
  end

  get 'contact(/:destination)', to: 'contact_messages#new'
  post :contact, to: 'contact_messages#create', as: :contact
  post :email_processor, to: 'griddler/emails#create'

  get '/robots'     => 'robots#show'
  get '/manifest'   => 'manifest#show', format: :json

  get  'start_group' => 'start_group#new'
  post 'start_group' => 'start_group#create'

  get 'dashboard'                          => 'application#boot_angular_ui', as: :dashboard
  get 'dashboard/:filter'                  => 'application#boot_angular_ui'
  get 'inbox'                              => 'application#boot_angular_ui', as: :inbox
  get 'groups'                             => 'application#boot_angular_ui', as: :groups
  get 'polls'                              => 'application#boot_angular_ui', as: :polls
  get 'explore'                            => 'application#boot_angular_ui', as: :explore
  get 'profile'                            => 'application#boot_angular_ui', as: :profile
  get 'email_preferences'                  => 'application#boot_angular_ui', as: :email_preferences
  get 'apps/registered'                    => 'application#boot_angular_ui'
  get 'apps/authorized'                    => 'application#boot_angular_ui'
  get 'apps/registered/:id'                => 'application#boot_angular_ui'
  get 'apps/registered/:id/:slug'          => 'application#boot_angular_ui'
  get 'd/:key/proposal/:proposal'          => 'application#boot_angular_ui', as: :discussion_motion
  get 'd/:key/comment/:comment'            => 'application#boot_angular_ui', as: :discussion_comment
  get 'd/:key/proposal/:proposal/outcome'  => 'application#boot_angular_ui', as: :discussion_motion_outcome
  get 'g/:key/membership_requests'         => 'application#boot_angular_ui', as: :group_membership_requests
  get 'g/:key/memberships'                 => 'application#boot_angular_ui', as: :group_memberships
  get 'g/:key/previous_proposals'          => 'application#boot_angular_ui', as: :group_previous_proposals
  get 'g/:key/previous_polls'              => 'application#boot_angular_ui', as: :group_previous_polls
  get 'g/:key/memberships/:username'       => 'application#boot_angular_ui', as: :group_memberships_username
  get 'p/new(/:type)'                      => 'application#boot_angular_ui', as: :new_poll

  get 'g/:key/export'                      => 'groups#export',               as: :group_export
  get 'g/:key(/:slug)'                     => 'groups#show',                 as: :group
  get 'd/:key(/:slug)'                     => 'discussions#show',            as: :discussion
  get 'd/:key/comment/:comment_id'         => 'discussions#show',            as: :comment
  get 'm/:key(/:slug)'                     => 'motions#show',                as: :motion
  get 'p/:key/share'                       => 'polls#share',                 as: :share_poll
  get 'p/:key(/:slug)'                     => 'polls#show',                  as: :poll
  get 'vote/:key(/:slug)'                  => 'polls#show'
  get 'u/:username/'                       => 'users#show',                  as: :user

  get '/notifications/dropdown_items'      => 'application#gone'
  get '/u/:key(/:stub)'                    => 'application#gone'
  get '/g/:key/membership_requests/new'    => 'application#gone'
  get '/comments/:id'                      => 'application#gone'

  get '/donate', to: redirect('https://loomio-donation.chargify.com/subscribe/9wnjv4g2cc9t/donation')
end
