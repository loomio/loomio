require 'delegate'

class DiscussionsQuery < SimpleDelegator
  def initialize relation, group, user=nil
    @group = group
    @user = user

    super relation
  end

  def self.for group, user=nil
    if user
      relation = Discussion.includes(:group => :memberships)
        .where "(discussions.group_id = ?
          OR (groups.parent_id = ? AND groups.archived_at IS NULL
          AND memberships.user_id = ?))",
          group.id, group.id, user.id
    else
      relation = Discussion.includes(:group)
        .where "(discussions.group_id = ? OR
          (groups.parent_id = ? AND groups.archived_at IS NULL
          AND groups.viewable_by = 'everyone'))", group.id, group.id
    end

    new relation, group, user
  end

  def with_current_motions
    includes(:motions).where('motions.phase = ?', "voting")
  end

  def with_current_motions_user_has_voted_on
    with_current_motions.includes(:motions => :votes).
    where('votes.user_id = ?', @user.id).
    order("last_comment_at DESC")
  end

  def with_current_motions_user_has_not_voted_on
    with_current_motions - with_current_motions_user_has_voted_on
  end
end