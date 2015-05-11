class Queries::VisibleDiscussions < Delegator
  def initialize(user: nil, groups: nil, group_ids: nil)
    @user = user

    if group_ids.nil? and groups.present?
      group_ids = Array(groups).map(&:id)
    end

    @relation = Discussion.joins(:group).where('groups.archived_at IS NULL').published
    @relation = self.class.apply_privacy_sql(user: @user, group_ids: group_ids, relation: @relation)

    super(@relation)
  end

  def __getobj__
    @relation
  end

  def __setobj__(obj)
    @relation = obj
  end

  def join_to_discussion_readers
    unless @joined_to_discussion_readers
      @relation = @relation.joins("LEFT OUTER JOIN discussion_readers dv ON dv.discussion_id = discussions.id AND dv.user_id = #{@user.id}")
      @joined_to_discussion_readers = true
    end
    self
  end

  def join_to_memberships
    unless @joined_to_memberships
      @relation = @relation.joins("LEFT OUTER JOIN memberships m ON m.user_id = #{@user.id} AND m.group_id = discussions.group_id")
      @joined_to_memberships = true
    end
    self
  end

  def join_to_motions
    unless @joined_to_motions
      @relation = @relation.joins("LEFT OUTER JOIN motions mo ON mo.discussion_id = discussions.id AND mo.closed_at IS NULL")
      @joined_to_motions = true
    end
  end

  def with_active_motions
    join_to_motions
    @relation = @relation.where('mo.id IS NOT NULL')
    self
  end

  def participating
    join_to_discussion_readers
    @relation = @relation.where('dv.participating = true')
    self
  end

  def unread
    join_to_discussion_readers
    @relation = @relation.where('dv.last_read_at IS NULL OR (dv.last_read_at < discussions.last_activity_at)')
    self
  end

  def muted
    join_to_discussion_readers && join_to_memberships
    @relation = @relation.where('(dv.volume = :mute) OR (dv.volume IS NULL AND m.volume = :mute) ', 
                                {mute: DiscussionReader.volumes[:mute]})
    self
  end

  def not_muted
    join_to_discussion_readers && join_to_memberships
    @relation = @relation.where('(dv.volume > :mute) OR (dv.volume IS NULL AND m.volume > :mute)',
                                {mute: DiscussionReader.volumes[:mute]})
    self
  end

  def recent
    @relation = @relation.where('last_activity_at > ?', 3.months.ago)
    self
  end

  def sorted_by_latest_motions
    @relation = @relation.joined_to_current_motion
                         .preload(:current_motion, {group: :parent})
                         .order('motions.closing_at ASC, last_activity_at DESC')
    self
  end

  def self.apply_privacy_sql(user: nil, group_ids: [], relation: nil)
    user_group_ids = user.nil? ? [] : user.cached_group_ids

    # select where
    # the discussion is public
    # or they are a member of the group
    # or user belongs to parent group and permission is inherited

    relation.where('discussions.group_id in (:group_ids) AND
                   ((discussions.private = false) OR
                    (discussions.group_id IN (:user_group_ids)) OR
                    (groups.parent_members_can_see_discussions = TRUE AND groups.parent_id IN (:user_group_ids)))',
                   group_ids: group_ids,
                   user_group_ids: user_group_ids)
  end

end
