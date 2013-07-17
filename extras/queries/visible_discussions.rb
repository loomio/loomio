class Queries::VisibleDiscussions < Delegator
  def initialize(user: nil, groups: nil)
    @user = user
    @groups = groups

    @relation = Discussion.joins(:group).where('archived_at IS NULL').order('last_comment_at DESC')

    if @user.present? && @groups.present?
      @relation = @relation.where("group_id IN (:group_ids) AND
                                  (group_id IN (:user_group_ids) OR groups.viewable_by = 'everyone')",
                                  group_ids: @groups.map(&:id),
                                  user_group_ids: @user.groups.map(&:id))
    elsif @user.present? && @groups.blank?
      @relation = @relation.where('group_id IN (:user_group_ids)', user_group_ids: @user.groups.map(&:id))
    elsif @user.blank? && @groups.present?
      @relation = @relation.where("group_id IN (:group_ids) AND groups.viewable_by = 'everyone'",
                                  group_ids: @groups.map(&:id))
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
    @relation.joins(:motions).merge(Motion.voting)
  end
end
