module GroupsHelper
  def group_permissions_label(option)
    return "Everyone" if option == :everyone
    return "Members" if option == :members
    return "Admins" if option == :admins
  end
end
