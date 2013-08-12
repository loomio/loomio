class GroupDiscussionsViewer
  def self.for(group: nil, user: nil)
    groups = groups_displayed(group: group, user: user)
    Queries::VisibleDiscussions.new(groups: groups, user: user)
  end

  def self.groups_displayed(group: nil, user: nil)
    groups = []
    ability = Ability.new(user)

    if ability.can?(:show, group)
      groups << group

      if group.members.include?(user)
        # dont include any subgroups unless the user is a member of them
        groups += group.subgroups.all.select{|g| g.members.include?(user) }
      else
        groups += group.subgroups.all.select{|g| ability.can?(:show, g) }
      end
    end

    groups
  end
end
