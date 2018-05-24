class Pending::BaseSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :name, :email, :email_status, :email_verified, :has_password, :identity_type,
             :avatar_kind, :avatar_initials, :email_hash, :avatar_url, :has_token, :auth_form

  def identity_type
    # included for oauth pending identities
  end

  def auth_form
    if user.email_status == :inactive && !has_token
      :inactive
    elsif (user.email_verified || has_token) && user.name
      :signIn
    else
      :signUp
    end
  end

  def has_token
    # pending login or invitation token
  end

  def avatar_kind
    user.avatar_kind
  end

  def avatar_initials
    user.avatar_initials
  end

  def email_hash
    Digest::MD5.hexdigest(email.to_s.downcase)
  end

  def avatar_url
    user.avatar_url(:large)
  end

  def email_status
    user.email_status
  end

  def email_verified
    user.email_verified
  end

  def has_password
    user.has_password
  end

  private

  def include_avatar_initials?
    avatar_kind == 'initials'
  end

  def include_email_hash?
    avatar_kind == 'gravatar'
  end

  def include_avatar_url?
    avatar_kind == 'uploaded'
  end

  def user
    @user ||= User.verified.find_by(email: email) || LoggedOutUser.new
  end
end
