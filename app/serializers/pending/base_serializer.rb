class Pending::BaseSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :name, :email, :email_status, :has_password, :identity_type
  attributes :avatar_kind, :avatar_initials, :gravatar_md5, :avatar_url

  def identity_type
    # no-op, only included for oauth pending identities
  end

  def avatar_kind
    user.avatar_kind
  end

  def avatar_initials
    user.avatar_initials
  end

  def gravatar_md5
    Digest::MD5.hexdigest(email.to_s.downcase)
  end

  def avatar_url
    user.avatar_url(:large)
  end

  def email_status
    user.email_status
  end

  def has_password
    user.encrypted_password.present?
  end

  private

  def include_avatar_initials?
    avatar_kind == 'initials'
  end

  def include_gravatar_md5?
    avatar_kind == 'gravatar'
  end

  def include_avatar_url?
    avatar_kind == 'uploaded'
  end

  def user
    @user ||= User.find_by_email(email) || LoggedOutUser.new
  end
end
