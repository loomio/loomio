class Pending::BaseSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :name, :email, :email_status, :email_verified, :has_password, :identity_type,
             :avatar_kind, :avatar_initials, :thumb_url, :avatar_url, :has_token, :auth_form

  def identity_type
    false
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

  def avatar_url
    user.avatar_url
  end

  def thumb_url
    user.thumb_url
  end

  def avatar_kind
    user.avatar_kind
  end

  def avatar_initials
    user.avatar_initials
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

  def user
    @user ||= User.verified.find_by(email: email) || LoggedOutUser.new
  end
end
