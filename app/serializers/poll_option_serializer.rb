class PollOptionSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :name, :icon_url
end
