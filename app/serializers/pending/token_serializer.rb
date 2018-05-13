class Pending::TokenSerializer < Pending::BaseSerializer
  def has_token
    true
  end

  def identity_type
    'loomio'
  end

  def name
    if object.is_reactivation
      user[:name]
    else
      user.name
    end
  end

  def email
    user.email
  end

  private

  def user
    @user ||= object.user
  end

  def email_status
    return 'active' if object.is_reactivation
    User.email_status_for(email)
  end
end
