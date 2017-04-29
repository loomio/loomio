class BasicUserSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :name, :email, :email_status, :has_password, :gravatar_md5, :avatar_url, :avatar_initials, :avatar_kind

  def has_password
    object.encrypted_password.present?
  end

  def avatar_url
    object.avatar_url(:large)
  end

  def gravatar_md5
    Digest::MD5.hexdigest(object.email.to_s.downcase)
  end
end
