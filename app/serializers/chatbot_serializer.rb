class ChatbotSerializer < ApplicationSerializer
  attributes :id, :kind, :webhook_kind, :group_id, :server, :channel, :event_kinds, :name, :notification_only
end
