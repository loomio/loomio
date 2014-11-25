class EventSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :sequence_id, :kind, :discussion_id, :created_at

  has_one :comment, serializer: CommentSerializer
  has_one :discussion, serializer: DiscussionSerializer
  has_one :proposal, serializer: MotionSerializer, root: :proposals
  has_one :vote, serializer: VoteSerializer
  has_one :comment_vote, serializer: CommentVoteSerializer
  has_one :actor, serializer: UserSerializer, root: 'users'

  %w[comment motion vote comment_vote].each do |kind|
    define_method kind do
      object.eventable if object.eventable_type == kind.classify
    end
  end

  def proposal
    motion
  end

  def comment
    case object.kind
    when 'comment_liked' then object.eventable.comment
    when 'new_comment' then object.eventable
    end
  end

  def discussion
    comment.discussion if comment.present?
  end

  def filter(keys)
    keys.delete(:comment)       unless ["Comment", "CommentVote"].include? object.eventable_type
    keys.delete(:discussion)    unless ["Comment", "CommentVote"].include? object.eventable_type
    keys.delete(:proposal)      unless object.eventable_type == 'Motion'
    keys.delete(:vote)          unless object.eventable_type == 'Vote'
    keys.delete(:comment_vote)  unless object.eventable_type == 'CommentVote'
    keys
  end

  def actor
    case object.kind
    when 'comment_liked' then object.eventable.user
    end
  end
end
