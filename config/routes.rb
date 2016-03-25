Loomio::Application.routes.draw do

  use_doorkeeper

  root to: 'root#index'

  namespace :development do
    get '/' => 'development#index'
    get ':action'
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

    resources :groups, only: [:show, :create, :update] do
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

  get "/browser_not_supported", to: "application#browser_not_supported"

  devise_for :users, controllers: { sessions: 'users/sessions',
                                    registrations: 'users/registrations',
                                    omniauth_callbacks: 'users/omniauth_callbacks' }

  namespace(:subscriptions) { post :webhook }
  resources :invitations, only: [:show]
  get '/users/invitation/accept' => redirect {|params, request|  "/invitations/#{request.query_string.gsub('invitation_token=','')}"}

  slug_regex = /[a-z0-9\-\_]*/i

  resources :groups,      path: 'g', slug: slug_regex, only: :show
  resources :discussions, path: 'd', slug: slug_regex, only: :show
  resources :motions,     path: 'm', slug: slug_regex, only: :show

  resources(:users,       path: 'u', only: []) do
    get ':username', action: :show
  end

  namespace :email_actions do
    get   'unfollow_discussion/:discussion_id/:unsubscribe_token', action: 'unfollow_discussion', as: :unfollow_discussion
    get   'follow_discussion/:discussion_id/:unsubscribe_token',   action: 'follow_discussion',   as: :follow_discussion
    get   'mark_summary_email_as_read', action: 'mark_summary_email_as_read', as: :mark_summary_email_as_read
    get   'mark_discussion_as_read/:discussion_id/:event_id/:unsubscribe_token', action: 'mark_discussion_as_read', as: :mark_discussion_as_read
  end

  scope module: :users do
    scope module: :email_preferences do
      get   '/email_preferences', action: 'edit',   as: :email_preferences
      put   '/email_preferences', action: 'update', as: :update_email_preferences
    end
  end

  scope controller: 'help' do
    get :help
    get :markdown
  end

  get 'contact(/:destination)', to: 'contact_messages#new', as: :contact

  get '/robots'     => 'robots#show'

  get  'start_group' => 'start_group#new'
  post 'start_group' => 'start_group#create'

  get 'dashboard'                          => 'application#show', as: :dashboard
  get 'inbox'                              => 'application#show', as: :inbox
  get 'groups'                             => 'application#show', as: :groups
  # get 'start_group'                        => 'application#show', as: :start_group
  get 'explore'                            => 'application#show', as: :explore
  get 'apps/registered'                    => 'application#show'
  get 'apps/authorized'                    => 'application#show'
  get 'apps/registered/:id'                => 'application#show'
  get 'apps/registered/:id/:slug'          => 'application#show'
  get 'd/:key/proposal/:proposal'          => 'application#show'
  get 'd/:key/comment/:comment'            => 'application#show'
  get 'd/:key/proposal/:proposal/:outcome' => 'application#show'
  get 'd/:key/:stub'                       => 'application#show'
  get 'g/:key/:stub'                       => 'application#show'
  get 'g/:key/memberships/:username'       => 'application#show'
end
