class Queries::VisibleDiscussions < Delegator
  def initialize(user: nil, groups: nil, group_ids: nil)
    @user = user

    if groups.present?
      group_ids = groups.map(&:id)
    end

    @relation = Discussion.joins(:group).where('archived_at IS NULL')

    if @user.present?
      @relation = @relation.select('discussions.*,
                                    1 as joined_to_discussion_reader,
                                    dv.id as viewer_id,
                                    dv.user_id as viewer_user_id,
                                    dv.read_comments_count as read_comments_count,
                                    dv.last_read_at as last_read_at,
                                    dv.following as viewer_following').
                              joins("LEFT OUTER JOIN discussion_readers dv ON
                                    dv.discussion_id = discussions.id AND dv.user_id = #{@user.id}")
    end

    if @user.present? && group_ids.present?
      @relation = @relation.where("group_id IN (:group_ids) AND
                                  (group_id IN (:user_group_ids) OR groups.viewable_by = 'everyone'
                                   OR (groups.viewable_by = 'parent_group_members' AND groups.parent_id IN (:user_group_ids)))",
                                  group_ids: group_ids,
                                  user_group_ids: @user.group_ids)
    elsif @user.present? && group_ids.blank?
      @relation = @relation.where('group_id IN (:user_group_ids)', user_group_ids: @user.group_ids)
    elsif @user.blank? && group_ids.present?
      @relation = @relation.where("group_id IN (:group_ids) AND groups.viewable_by = 'everyone'",
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
    @relation = @relation.where('(dv.last_read_at < discussions.last_comment_at) OR dv.last_read_at IS NULL')
    self
  end

  def followed
    @relation = @relation.where('dv.following = ? OR dv.following IS NULL', true)
    self
  end

  def without_open_motions
    @relation = @relation.where("discussions.id NOT IN (SELECT discussion_id FROM motions WHERE id IS NOT NULL AND closed_at IS NULL)")
    self
  end

  def with_open_motions
    @relation = @relation.joins(:motions).merge(Motion.voting)
    self
  end
end
