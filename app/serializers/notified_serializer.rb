class NotifiedSerializer < ActiveModel::Serializer
  attributes :id, :type, :title, :subtitle, :icon_url, :notified_ids, :avatar_initials
end
