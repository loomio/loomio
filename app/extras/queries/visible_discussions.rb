class Queries::VisibleDiscussions < Delegator
  def initialize(user:, groups: nil, group_ids: nil)
    @user = user || LoggedOutUser.new
    @group_ids = group_ids.presence || Array(groups).map(&:id).presence || user.group_ids

    @relation = Discussion.
                  joins(:group).
                  where('groups.archived_at IS NULL').
                  published.
                  includes(:author, {current_motion: [:author, :outcome_author]}, {group: [:parent]})
    @relation = self.class.apply_privacy_sql(user: @user, group_ids: @group_ids, relation: @relation)
    
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

  def join_to_starred_motions
    unless @joined_to_starred_motions
      join_to_discussion_readers
      @relation = @relation.joins("LEFT OUTER JOIN motions smo ON smo.discussion_id = discussions.id AND smo.closed_at IS NULL AND dv.starred = true")
      @joined_to_starred_motions = true
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

  def starred
    join_to_discussion_readers
    @relation = @relation.where('dv.starred = true')
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

  def sorted_by_latest_activity
    @relation = @relation.order(last_activity_at: :desc)
    self
  end

  def sorted_by_importance
    if @user.is_logged_in?
      join_to_starred_motions && join_to_motions
      @relation = @relation.order('smo.closing_at ASC, mo.closing_at ASC, dv.starred DESC NULLS LAST, last_activity_at DESC')
    else
      @relation = @relation.order(last_activity_at: :desc)
    end
    self
  end

  def self.apply_privacy_sql(user: nil, group_ids: [], relation: nil)
    user ||= LoggedOutUser.new
    group_ids = group_ids.presence || Group.visible_to_public.pluck(:id) unless user.is_logged_in?

    # select where
    # the discussion is public
    # or they are a member of the group
    # or user belongs to parent group and permission is inherited
    relation.where('discussions.group_id in (:group_ids) AND
                   ((discussions.private = false) OR
                    (discussions.group_id IN (:user_group_ids)) OR
                    (groups.parent_members_can_see_discussions = TRUE AND groups.parent_id IN (:user_group_ids)))',
                   group_ids: group_ids,
                   user_group_ids: user.group_ids)
  end

end
