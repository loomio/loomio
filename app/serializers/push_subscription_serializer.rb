class PushSubscriptionSerializer < ApplicationSerializer
  attributes :id, :name, :user_agent, :last_seen_at, :expires_at, :created_at
end
