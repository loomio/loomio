class OauthApplicationSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id, :name, :redirect_uri, :uid, :secret, :authorized

  def authorized
    object.access_tokens.where(resource_owner_id: user_id, revoked_at: nil).any?
  end

  def user_id
    (scope || {})[:user_id]
  end
end
