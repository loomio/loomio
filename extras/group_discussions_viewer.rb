class GroupDiscussionsViewer
  def self.for(group, user)
    groups = groups_shown_when_viewing_group(group, user)
    Queries::VisibleDiscussions.new(groups: groups, user: user)
  end

  def self.groups_shown_when_viewing_group(group, user)
    groups = []
    if user && user.is_group_member?(group)
      groups << group
      groups += group.subgroups.joins(:memberships).
                      where('memberships.user_id = :user_id', user_id: user.id)
    elsif group.viewable_by == 'everyone'
      groups << group
      groups += group.subgroups.where("viewable_by = 'everyone'")
    end
    groups
  end
end
