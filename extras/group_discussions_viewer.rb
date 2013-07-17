class GroupDiscussionsViewer
  def self.for(group, user)
    @relation = Queries::VisibleDiscussions.
                new(group: group, user: user)
    @relation
  end

  def self.groups_shown_when_viewing_group(group, user)
    groups = []
    if user.is_group_member?(group)
      groups << group
      group.subgroups.each do |subgroup|
        if user.is_group_member?(subgroup)
          groups << subgroup
        end
      end
    else
      if group.viewable_by == 'everyone'
        groups << group
        group.subgroups.each do |subgroup|
          if subgroup.viewable_by == 'everyone'
            groups << subgroup
          end
        end
      end
    end
    groups
  end
end
