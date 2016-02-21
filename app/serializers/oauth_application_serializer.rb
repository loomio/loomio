class OauthApplicationSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id, :name, :redirect_uris

  def redirect_uris
    object.redirect_uri.split("\r\n")
  end
end
