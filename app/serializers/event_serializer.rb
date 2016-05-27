class EventSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :sequence_id, :kind, :discussion_id, :created_at

  has_one :actor, serializer: UserSerializer, root: 'users'
  has_one :eventable, polymorphic: true

  def eventable
    # comment_liked serializes out a CommentVote, which is worthless to us on the client (and... in general.)
    # so, we'll take the Comment instead.
    if object.eventable.is_a?(CommentVote)
      object.eventable.comment
    else
      object.eventable
    end
  end

  def actor
    object.user || object.eventable&.user
  end
end
