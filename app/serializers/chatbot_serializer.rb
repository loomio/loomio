class ChatbotSerializer < ApplicationSerializer
  attributes :id, :kind, :webhook_kind, :group_id, :server, :channel, :event_kinds, :name, :notification_only

  def include_server?
    scope && scope[:current_user_is_admin]
  end

  def include_channel?
    include_server?
  end
end
