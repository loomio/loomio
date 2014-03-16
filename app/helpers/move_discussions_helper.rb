module MoveDiscussionsHelper
  def destinations_for(discussion: nil, user: nil)
    source_group = discussion.group
    # can't move the discussion unless the user belongs to the group it's currently in
    return [] unless user.adminable_groups.include? source_group
    user.groups.uniq - [source_group]
  end

end
