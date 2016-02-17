class DiscussionSerializer < Simple::DiscussionSerializer

  attributes :key,
             :last_item_at,
             :last_comment_at,
             :last_activity_at,
             :created_at,
             :updated_at,
             :archived_at,
             :comments_count,
             :private,
             :versions_count

  attributes_from_reader :discussion_reader_id,
                         :discussion_reader_volume,
                         :last_read_at,
                         :read_comments_count,
                         :participating,
                         :starred

  has_one :author, serializer: UserSerializer, root: 'users'
  has_one :group, serializer: GroupSerializer, root: 'groups'
  has_one :active_proposal, serializer: MotionSerializer, root: 'proposals'
  has_one :active_proposal_vote, serializer: VoteSerializer, root: 'votes'

  def include_active_proposal_vote?
    reader.present? && active_proposal.present?
  end

  def active_proposal_vote
    active_proposal.votes.find_by(user_id: reader.user_id)
  end

  def active_proposal
    @active_proposal ||= object.current_motion
  end

  def reader
    @reader ||= scope[:reader_cache].get_for(object) if scope[:reader_cache]
  end

  def scope
    super || {}
  end

end
