module MoveDiscussionsHelper
  def destinations_for(discussion: nil, user: nil)
    source_group = discussion.group

    unless user.adminable_groups.include? source_group
      # can't move the discussion unless the user belongs to the group it's currently in
      return []
    end

    groups_in_family = []
    groups_in_family += [source_group.parent]
    groups_in_family += [source_group.subgroups]
    groups_in_family += [source_group.parent.subgroups] if source_group.parent.present?

    (groups_in_family.flatten & user.adminable_groups).uniq - [source_group]
  end

end
