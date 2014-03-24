class Queries::VisibleDiscussions < Delegator
  def initialize(user: nil, groups: nil, group_ids: nil)
    @user = user

    if groups.present?
      group_ids = Array(groups).map(&:id)
    end

    @relation = Discussion.joins(:group).merge(Group.published).published

    if @user.present?
      @relation = @relation.joins("LEFT OUTER JOIN discussion_readers dv ON dv.discussion_id = discussions.id AND dv.user_id = #{@user.id}")
    end

    if @user.present? && group_ids.present?
                                  # group_id is in requested group_ids
      @relation = @relation.where("group_id IN (:group_ids) AND
                                  -- the discussion is public
                                  ((discussions.private = FALSE AND groups.private_discussions_only = FALSE) OR
                                  -- or they are a member of the group
                                   (group_id IN (:user_group_ids)) OR
                                  -- or user belongs to parent group and permission is inherited
                                  (groups.visible_to_parent_members = TRUE AND groups.parent_id IN (:user_group_ids)))",
                                  group_ids: group_ids,
                                  user_group_ids: @user.cached_group_ids)
    elsif @user.present? && group_ids.blank?
      @relation = @relation.where('group_id IN (:user_group_ids)', user_group_ids: @user.cached_group_ids)
    elsif @user.blank? && group_ids.present?
      @relation = @relation.where("group_id IN (:group_ids) AND discussions.private = FALSE AND groups.private_discussions_only = FALSE",
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
end
