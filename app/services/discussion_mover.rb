class DiscussionMover

  def self.destination_groups(group, user)
    destinations = []
    destinations += parent_destination(group, user) if group.is_a_subgroup?
    destinations += subgroup_destinations(group, user)
    destinations
  end

  def self.parent_destination(group, user)
    return [] unless can_move?(user, group, group.parent)

    [[group.parent.name, group.parent.id]]
  end

  def self.subgroup_destinations(group, user)
    parent = group.parent || group
    subgroup_destinations = []
    parent.subgroups.each do |subgroup|
      if subgroup != group && can_move?(user, group, subgroup)
        subgroup_destinations << [subgroup.name, subgroup.id]
      end
    end
    subgroup_destinations
  end

  def self.can_move?(user, origin, destination)
    # couldn't figure out how to do this with cancan
    destination.admins.include?(user) && origin.admins.include?(user)
  end
end
