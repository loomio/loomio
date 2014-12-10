class EventSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :sequence_id, :kind, :discussion_id, :created_at

  has_one :comment, serializer: CommentSerializer
  has_one :discussion, serializer: DiscussionSerializer
  has_one :proposal, serializer: MotionSerializer, root: 'proposals'
  has_one :vote, serializer: VoteSerializer
  has_one :actor, serializer: UserSerializer, root: 'users'
  has_one :membership_request, serializer: MembershipRequestSerializer, root: 'membership_requests'

  def group_kinds
    ['new_discussion', 'user_added_to_group', 'membership_request', 'membership_request_approved']
  end

  def group
    object.eventable.try(:group) || object.group
  end

  def discussion_kinds
    ['comment_liked', 'new_discussion', 'new_motion', 'new_comment', 'user_mentioned']
  end

  def discussion
    object.eventable.try(:discussion) || object.eventable
  end

  def include_discussion?
    discussion_kinds.include? object.kind
  end

  def comment_kinds
    ['comment_liked', 'new_comment']
  end

  def comment
    object.eventable.try(:comment) || object.eventable
  end

  def include_comment?
    comment_kinds.include? object.kind
  end

  def proposal_kinds
    ['motion_blocked', 'motion_closing_soon', 'motion_outcome_created', 'motion_outcome_updated', 'new_motion', 'new_vote']
  end

  def proposal
    object.eventable.try(:motion) || object.eventable
  end

  def include_proposal?
    proposal_kinds.include? object.kind
  end

  def include_membership_request?
    ['membership_requested', 'membership_request_approved'].include? object.kind
  end

  def membership_request
    object.eventable
  end

  def vote_kinds
    ['new_vote']
  end

  def vote
    object.eventable
  end

  def include_vote?
    vote_kinds.include? object.kind
  end

  def actor
    object.eventable.try(:user)
  end
end
