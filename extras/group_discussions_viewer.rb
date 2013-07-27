class GroupDiscussionsViewer
  def self.for(group: nil, user: nil)
    groups = groups_displayed(group: group, user: user)
    Queries::VisibleDiscussions.new(groups: groups, user: user)
  end

  def self.groups_displayed(group: nil, user: nil)
    groups = group.subgroups.all.select {|g| g.viewable_by? user}
    groups << group if group.viewable_by?(user)
    groups
  end
end
