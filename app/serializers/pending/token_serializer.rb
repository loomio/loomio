class Pending::TokenSerializer < Pending::BaseSerializer
  attribute :has_token

  def has_token
    true
  end

  def identity_type
    'loomio'
  end

  def name
    user.name
  end

  def email
    user.email
  end

  private

  def user
    @user ||= object.user
  end

  def email_status
    User.email_status_for(email)
  end
end
