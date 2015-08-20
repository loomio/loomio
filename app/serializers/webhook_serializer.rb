class WebhookSerializer < ActiveModel::Serializer
  attributes :text, :username, :attachments, :icon_url
end
