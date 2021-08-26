class Restricted::GroupSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :name, :logo_url, :cover_url
end
