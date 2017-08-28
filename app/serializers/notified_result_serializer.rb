class NotifiedResultSerializer < ActiveModel::Serializer
  attributes :id, :type, :title, :subtitle, :icon_url, :notified_ids
end
