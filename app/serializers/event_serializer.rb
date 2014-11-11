class EventSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :sequence_id, :kind, :discussion_id, :created_at

  has_one :comment, serializer: CommentSerializer
  has_one :proposal, serializer: MotionSerializer, root: :proposals
  has_one :vote, serializer: VoteSerializer
  has_one :comment_vote, serializer: CommentVoteSerializer

  %w[comment motion vote comment_vote].each do |kind|
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
    keys.delete(:comment_vote) unless object.eventable_type == 'CommentVote'
    keys
  end
end
