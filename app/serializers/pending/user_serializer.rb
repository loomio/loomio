class Pending::UserSerializer < Pending::BaseSerializer
  private

  def user
    object
  end

  def email_status
    User.email_status_for(object.email)
  end
end
