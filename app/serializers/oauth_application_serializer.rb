class OauthApplicationSerializer < ActiveModel::Serializer
  embed :ids, include: true

  attributes :id, :name, :redirect_uri, :uid, :secret, :authorized, :logo_url

  def logo_url
    object.logo.url
  end

  def is_owner?
    object.owner_id == user_id
  end
  alias :include_uid? :is_owner?
  alias :include_secret? :is_owner?

  def authorized
    object.access_tokens.where(resource_owner_id: user_id, revoked_at: nil).any?
  end

  def user_id
    (scope || {})[:user_id]
  end
end
