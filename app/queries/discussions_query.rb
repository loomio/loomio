require 'delegate'

class DiscussionsQuery < SimpleDelegator
  def initialize(relation, group, user=nil)
    @group = group
    @user = user

    super(relation)
  end

  class << self
    def for(group, user=nil)
      if user
        if user.is_group_member?(group)
          relation = Discussion.includes(:group => :memberships).
                     where("discussions.group_id = ?
                     OR (groups.parent_id = ? AND groups.archived_at IS NULL
                     AND memberships.user_id = ?)",
                     group.id, group.id, user.id)
        elsif user.is_parent_group_member?(group)
          relation = Discussion.includes(:group).
                     where("
                     discussions.group_id = ?
                     AND (groups.viewable_by = 'everyone'
                     OR groups.viewable_by = 'parent_group_members')",
                     group.id)
        else
          relation = publicly_viewable_discussions_for(group)
        end
      else
        relation = publicly_viewable_discussions_for(group)
      end
      relation = relation.order("last_comment_at DESC")

      new(relation, group, user)
    end

    private

    def publicly_viewable_discussions_for(group)
      Discussion.includes(:group).
                 where(
                 "discussions.group_id = ? AND groups.viewable_by = 'everyone'
                 OR (groups.parent_id = ? AND groups.archived_at IS NULL
                 AND groups.viewable_by = 'everyone')", group.id, group.id)
    end
  end

  def with_current_motions
    includes(:motions).where('motions.phase = ?', "voting")
  end

  def with_current_motions_user_has_voted_on
    return [] unless @user
    with_current_motions.includes(:motions => :votes).
    where('votes.user_id = ?', @user.id)
  end

  def with_current_motions_user_has_not_voted_on
    with_current_motions - with_current_motions_user_has_voted_on
  end

  def without_current_motions
    includes(:motions).where("discussions.id NOT IN (SELECT discussion_id FROM motions WHERE phase = 'voting')")
  end
end