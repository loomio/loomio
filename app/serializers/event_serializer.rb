class EventSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :sequence_id, :kind, :discussion_id

  has_one :comment, serializer: CommentSerializer
  has_one :proposal, serializer: MotionSerializer, root: :proposals
  has_one :vote, serializer: VoteSerializer

  %w[comment motion vote].each do |kind|
    define_method kind do
      object.eventable if object.eventable_type == kind.classify
    end
  end

  def proposal
    motion
  end

  def filter(keys)
    keys.delete(:comment) unless object.eventable_type == 'Comment'
    keys.delete(:proposal) unless object.eventable_type == 'Motion'
    keys.delete(:vote) unless object.eventable_type == 'Vote'
    keys
  end
end
