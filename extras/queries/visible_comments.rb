class Queries::VisibleComments < Delegator
  def initialize(user: nil, groups: nil, group_ids: nil)
    @user = user

    group_ids = []
    if groups.present?
      group_ids = Array(groups).map(&:id)
    end

    @relation = Comment.joins(:discussion => :group).merge(Group.published).preload(:discussion)
    @relation = Queries::VisibleDiscussions.apply_privacy_sql(user: @user, group_ids: group_ids, relation: @relation)

    super(@relation)
  end

  def __getobj__
    @relation
  end

  def __setobj__(obj)
    @relation = obj
  end

end
