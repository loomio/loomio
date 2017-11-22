class Events::BaseSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :sequence_id, :position, :depth, :child_count, :kind, :discussion_id, :created_at, :eventable_id, :eventable_type

  has_one :actor, serializer: UserSerializer, root: :users
  has_one :eventable, polymorphic: true
  has_one :parent, serializer: Events::BaseSerializer, root: :events

  def actor
    object.user || object.eventable&.user
  end
end
