class EventSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :sequence_id, :kind, :discussion_id, :created_at

  has_one :actor, serializer: UserSerializer, root: 'users'
  has_one :membership, serializer: MembershipSerializer, root: 'memberships'
  has_one :membership_request, serializer: MembershipRequestSerializer, root: 'membership_requests'
  has_one :comment, serializer: CommentSerializer
  has_one :discussion, serializer: DiscussionSerializer
  has_one :proposal, serializer: MotionSerializer, root: 'proposals'
  has_one :group, serializer: GroupSerializer, root: 'groups'
  has_one :vote, serializer: VoteSerializer
  has_one :version, serializer: VersionSerializer

  def actor
    object.user || object.eventable.try(:user)
  end

  def group
    object.eventable.try(:group) || object.eventable
  end

  def membership
    object.eventable
  end

  def membership_request
    object.eventable
  end

  def version
    object.eventable
  end

  def discussion
    object.eventable.try(:discussion) || object.eventable
  end

  def proposal
    case object.kind
    when 'motion_updated' then object.eventable.record
    else 
      object.eventable.try(:motion) || object.eventable
    end
  end

  def comment
    object.eventable.try(:comment) || object.eventable
  end

  def vote
    object.eventable
  end

  def include_version?
    ['discussion_edited', 'motion_edited'].include? object.kind
  end

  def include_membership?
    membership_kinds.include? object.kind
  end

  def include_membership_request?
    membership_request_kinds.include? object.kind
  end

  def include_group?
    group_kinds.include? object.kind
  end

  def include_discussion?
    discussion_kinds.include? object.kind
  end

  def include_comment?
    comment_kinds.include? object.kind
  end

  def include_proposal?
    proposal_kinds.include? object.kind
  end

  def include_vote?
    vote_kinds.include? object.kind
  end

  def group_kinds
    ['new_discussion',
     'user_added_to_group',
     'discussion_moved'] +
     membership_request_kinds
  end

  def membership_kinds
    ['user_added_to_group',
     'membership_request_approved',
     'invitation_accepted',
     'new_coordinator']
  end

  def membership_request_kinds
    ['membership_requested']
  end

  def discussion_kinds
    ['new_discussion'] +
    comment_kinds +
    proposal_kinds
  end

  def comment_kinds
    ['comment_liked',
     'new_comment',
     'comment_replied_to',
     'user_mentioned']
  end

  def proposal_kinds
    ['motion_blocked',
     'motion_closing_soon',
     'motion_closed',
     'motion_closed_by_user',
     'motion_outcome_created',
     'motion_outcome_updated',
     'new_motion'] +
     vote_kinds
  end

  def vote_kinds
    ['new_vote']
  end
end
