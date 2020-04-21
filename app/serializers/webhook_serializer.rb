class WebhookSerializer < ApplicationSerializer
  attributes :id, :name, :url, :format, :group_id
end
