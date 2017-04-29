class UserEmailStatusSerializer < ActiveModel::Serializer
  attributes :email_status, :has_password

  def has_password
    object.encrypted_password.present?
  end
end
