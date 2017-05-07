class IdentitySerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :identity_type, :user_id, :name, :email, :logo, :custom_fields
end
