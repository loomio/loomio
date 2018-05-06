class MemberSerializer < ActiveModel::Serializer
  attributes :key, :priority, :type, :title, :subtitle, :logo_url, :logo_type, :last_notified_at
end
