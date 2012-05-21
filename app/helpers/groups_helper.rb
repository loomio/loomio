module GroupsHelper
  def group_permissions_label(option)
    return "Everyone" if option == :everyone
    return "Members" if option == :members
    return "Parent group members" if option == :parent_group_members
    return "Admins" if option == :admins
  end
  
  def display_subgroups_block?(group)
    current_user || group.subgroups.present?
  end
end
