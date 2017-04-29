class UserEmailStatusSerializer < ActiveModel::Serializer
  attributes :email_status, :has_password, :first_name

  def first_name
    (object.name || object.username).to_s.split(' ').first
  end

  def has_password
    object.encrypted_password.present?
  end
end
