class Pending::BaseSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :name, :email, :email_status, :has_password

  def email_status
    user.email_status
  end

  def has_password
    user.encrypted_password.present?
  end

  private

  def user
    @user ||= User.find_by_email(email) || LoggedOutUser.new
  end
end
