class NotifiedSerializer < ActiveModel::Serializer
  attributes :id, :title, :subtitle, :icon_url, :notified_ids
end
