class IdentitySerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :identity_type, :user_id, :name, :email, :logo, :custom_fields, :email_status

  def email_status
    (object.user || LoggedOutUser.new).email_status
  end
end
