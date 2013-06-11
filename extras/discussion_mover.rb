class DiscussionMover

  def self.destination_groups(group, user)
    destinations = []
    destinations << [group.parent.name, group.parent.id] if group.is_a_subgroup? && user.is_group_admin?(group.parent)
    destinations += subgroup_destinations(group, user)
    destinations
  end

  def self.subgroup_destinations(group, user)
    subgroup_destinations = []
    parent = group.parent || group
    parent.subgroups.each do |subgroup|
      if user.is_group_admin?(subgroup) && subgroup != group
        subgroup_destinations << [subgroup.name, subgroup.id]
      end
    end
    subgroup_destinations
  end

  def self.can_move?(user, origin, destination)
    destination.admins.include?(user) && origin.admins.include?(user)
  end
end
