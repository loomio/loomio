module GroupsHelper
  def display_subgroups_block?(group)
    group.parent.nil? && (group.subgroups.present? || (current_user && group.users_include?(current_user)))
  end
end
