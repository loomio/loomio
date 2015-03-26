class GroupDiscussionsViewer
  def self.for(group: nil, user: nil, filter: nil)
    groups = groups_displayed(group: group, user: user)
    Queries::VisibleDiscussions.new(groups: groups, user: user).tap do |discussions|
      discussions = discussions.unread if filter == 'show_unread'
    end
  end

  def self.groups_displayed(group: nil, user: nil)
    groups = []
    ability = Ability.new(user)

    if ability.can?(:show, group)
      groups << group
      groups += group.subgroups.all.select{|g| ability.can?(:show, g) }
    end

    groups
  end
end
