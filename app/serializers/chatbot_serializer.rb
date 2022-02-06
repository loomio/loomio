class ChatbotSerializer < ApplicationSerializer
  attributes :id, :group_id, :server, :username, :password, :channel
end
