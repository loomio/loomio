class Pending::UserSerializer < Pending::BaseSerializer
  attributes :legal_accepted_at
  private

  def has_token
    Hash(scope)[:has_token]
  end

  def user
    object
  end

  def email_status
    User.email_status_for(object.email)
  end
end
