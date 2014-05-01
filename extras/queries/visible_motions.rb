class Queries::VisibleMotions < Delegator
  def initialize(user: nil, groups: nil, group_ids: nil)
    @user = user

    group_ids = []
    if groups.present?
      group_ids = Array(groups).map(&:id)
    end

    @relation = Motion.joins(:discussion => :group).merge(Group.published).preload(:discussion)

    if @user.present?
      @relation = @relation.select('motions.*,
                                    1 as joined_to_motion_reader,
                                    mr.id as motion_reader_id,
                                    mr.user_id as motion_reader_user_id,
                                    mr.read_votes_count as read_votes_count,
                                    mr.read_activity_count as read_activity_count,
                                    mr.last_read_at as last_read_at,
                                    mr.following as viewer_following').
                              joins("LEFT OUTER JOIN motion_readers mr ON
                                    mr.motion_id = motions.id AND mr.user_id = #{@user.id}")
    end

    if @user.present? && !group_ids.empty?
      @relation = @relation.where("discussions.group_id IN (:group_ids) AND
                                  (discussions.group_id IN (:user_group_ids) OR groups.privacy = 'public'
                                   OR (groups.viewable_by_parent_members = TRUE AND groups.parent_id IN (:user_group_ids)))",
                                  group_ids: group_ids,
                                  user_group_ids: @user.cached_group_ids)
    elsif @user.present? && group_ids.empty?
      @relation = @relation.where('discussions.group_id IN (:user_group_ids)', user_group_ids: @user.cached_group_ids)
    elsif @user.blank? && !group_ids.empty?
      @relation = @relation.where("discussions.group_id IN (:group_ids) AND groups.privacy = 'public'",
                                  group_ids: group_ids)
    else
      @relation = []
    end

    super(@relation)
  end

  def __getobj__
    @relation
  end

  def __setobj__(obj)
    @relation = obj
  end

  def unread
    @relation = @relation.where('(mr.last_read_at < motions.last_vote_at) OR mr.last_read_at IS NULL')
    self
  end

  def followed
    @relation = @relation.where('mr.following = ? OR mr.following IS NULL', true)
    self
  end
end
