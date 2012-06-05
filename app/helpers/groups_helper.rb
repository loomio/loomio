module GroupsHelper
  def group_permissions_label(option)
    return "Everyone" if option == :everyone
    return "Members" if option == :members
    return "Parent group members" if option == :parent_group_members
    return "Admins" if option == :admins
  end

  def display_subgroups_block?(group)
    group.parent.nil? && (group.subgroups.present? || (current_user && group.users_include?(current_user)))
  end

  def discussion_display_type(discussion)
    return "motion" if current_user && discussion.current_motion && (not discussion.current_motion.user_has_voted?(current_user))
    return "active" if Time.now() - 2.weeks < discussion.updated_at
    return "inactive"
  end
end
