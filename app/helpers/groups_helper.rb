module GroupsHelper
  def display_subgroups_block?(group)
    group.parent.nil? && (group.subgroups.present? || (current_user && group.users_include?(current_user)))
  end
  
  def activity_count_for_group(group, user)
    user ? user.group_activity_count(group) : 0
  end
  
  def enabled_icon_class_for_group(group, user)
    if activity_count_for_group(group, user) > 0
      "enabled-icon"
    else
      "disabled-icon"
    end
  end
end
