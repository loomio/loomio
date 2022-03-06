class ChatbotSerializer < ApplicationSerializer
  attributes :id, :kind, :group_id, :server, :access_token, :channel, :event_kinds
end
