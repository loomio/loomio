class Queries::VisiblePolls < Delegator
  def initialize(user: nil, groups: nil, group_ids: nil)
    @user = user || LoggedOutUser.new
    @group_ids = group_ids.presence || Array(groups).map(&:id)

    @relation = Poll.joins(discussion: :group).includes(:discussion).where('groups.archived_at IS NULL')
    @relation = Queries::VisibleDiscussions.apply_privacy_sql(user: @user, group_ids: @group_ids, relation: @relation)

    super(@relation)
  end

  def closed
    @relation.closed
  end

  def __getobj__
    @relation
  end

  def __setobj__(obj)
    @relation = obj
  end
end
