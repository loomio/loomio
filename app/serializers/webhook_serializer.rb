class WebhookSerializer < ApplicationSerializer
  attributes :id, :name, :url, :format, :group_id, :include_body, :include_subgroups, :event_kinds, :permissions, :token
end
