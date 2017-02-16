class VisitorSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :name, :email, :participation_token
end
