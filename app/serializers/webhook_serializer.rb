class WebhookSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :name, :url, :format, :group_id
end
