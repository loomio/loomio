class Simple::EventSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :kind, :created_at
  has_one :eventable, polymorphic: true
  has_one :user
end
