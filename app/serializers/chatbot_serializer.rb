class ChatbotSerializer < ApplicationSerializer
  attributes :id, :kind, :group_id, :server, :username, :password, :channel, :event_kinds
end
