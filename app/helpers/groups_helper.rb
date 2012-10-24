module GroupsHelper
  def display_subgroups_block?(group)
    group.parent.nil? && (group.subgroups.present? || (current_user && group.users_include?(current_user)))
  end

  def css_for_privacy_link(group, link)
    current_privacy_setting = String(group.viewable_by)
    return "icon-ok" if link == current_privacy_setting
  end
end
