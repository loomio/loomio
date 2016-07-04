class Events::BaseSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :sequence_id, :kind, :discussion_id, :created_at

  has_one :actor, serializer: UserSerializer, root: :users
  has_one :eventable, polymorphic: true

  def actor
    object.user || object.eventable&.user
  end
end
