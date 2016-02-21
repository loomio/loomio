class OauthApplicationSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id, :name, :redirect_uri
end
