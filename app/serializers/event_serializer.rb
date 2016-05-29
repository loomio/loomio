class EventSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :sequence_id, :kind, :discussion_id, :created_at

  has_one :actor, serializer: UserSerializer, root: :users
  has_one :eventable, polymorphic: true
  has_one :proposal, serializer: MotionSerializer, root: :proposals
  has_one :discussion, serializer: DiscussionSerializer
  has_one :moved_discussion, serializer: DiscussionSerializer, root: :discussions

  def eventable_is_proposal?
    eventable.is_a?(Motion)
  end
  alias :include_proposal? :eventable_is_proposal?
  alias :include_discussion? :eventable_is_proposal?

  def include_moved_discussion?
    object.kind == 'discussion_moved'
  end

  def proposal
    eventable
  end

  def discussion
    eventable.discussion
  end

  def moved_discussion
    object.discussion
  end

  def eventable
    # comment_liked serializes out a CommentVote, which is worthless to us on the client (and... in general.)
    # so, we'll take the Comment instead.
    @eventable ||= if object.eventable.is_a?(CommentVote)
      object.eventable.comment
    else
      object.eventable
    end
  end

  def actor
    object.user || eventable&.user
  end
end
