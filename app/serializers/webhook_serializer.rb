class WebhookSerializer < ApplicationSerializer
  attributes :id, :name, :url, :format, :group_id, :include_body, :event_kinds
end
