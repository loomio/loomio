class ChatbotSerializer < ApplicationSerializer
  attributes :id, :kind, :group_id, :server, :channel, :event_kinds, :name
end
