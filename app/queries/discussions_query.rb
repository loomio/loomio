require 'delegate'

class DiscussionsQuery < SimpleDelegator
  def initialize(user, group)
    if user
      relation = Discussion.includes(:group => :memberships)
        .where("(discussions.group_id = ?
          OR (groups.parent_id = ? AND groups.archived_at IS NULL
          AND memberships.user_id = ?))",
          group.id, group.id, user.id)
    else
      relation = Discussion.includes(:group)
        .where("(discussions.group_id = ? OR (groups.parent_id = ? AND groups.archived_at IS NULL
          AND groups.viewable_by = 'everyone'))", group.id, group.id)
    end
    super(relation)
  end
end