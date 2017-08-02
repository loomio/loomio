class ContactMessageSerializer < ActiveModel::Serializer
  attributes :name, :email, :message
end
