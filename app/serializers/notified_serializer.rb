class NotifiedSerializer < ActiveModel::Serializer
  attributes :id, :type, :title, :subtitle, :logo_type, :logo_url, :notified_ids
end
