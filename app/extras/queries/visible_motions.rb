class Queries::VisibleMotions < Delegator
  def initialize(user: nil, groups: nil, group_ids: nil)
    @user = user || LoggedOutUser.new
    @group_ids = group_ids.presence || Array(groups).map(&:id)

    @relation = Motion.joins(discussion: :group).includes(:discussion).where('groups.archived_at IS NULL')

    if @user.is_logged_in?
      @relation = @relation.joins("LEFT OUTER JOIN motion_readers mr ON mr.motion_id = motions.id AND mr.user_id = #{@user.id}")
    end

    @relation = Queries::VisibleDiscussions.apply_privacy_sql(user: @user, group_ids: @group_ids, relation: @relation)

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
