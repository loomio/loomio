class Queries::VisibleMotions < Delegator
  def initialize(user: nil, groups: nil, group_ids: nil)
    @user = user

    group_ids = []
    if groups.present?
      group_ids = Array(groups).map(&:id)
    end

    @relation = Motion.joins(:discussion => :group).merge(Group.published).preload(:discussion)

    if @user.present?
      @relation = @relation.joins("LEFT OUTER JOIN motion_readers mr ON mr.motion_id = motions.id AND mr.user_id = #{@user.id}")
    end

    @relation = Queries::VisibleDiscussions.apply_privacy_sql(user: @user, group_ids: group_ids, relation: @relation)

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
end
