module GroupsHelper
  def viewable_by_label(option)
    return "Everyone" if option == :everyone
    return "Members" if option == :members
  end
end
