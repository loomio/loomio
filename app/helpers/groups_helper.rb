module GroupsHelper
  def css_for_privacy_link(group, link)
    current_privacy_setting = String(group.viewable_by)
    return "icon-ok" if link == current_privacy_setting
  end

  def display_subgroups_block?(group)
    group.parent.nil? && (group.subgroups.present? || (current_user && group.users_include?(current_user)))
  end

  def logged_in_member_can_invite?(group)
    user_signed_in? && current_user.is_group_member?(group) && group.members_can_invite?
  end

  def show_next_steps?(group)
    user_signed_in? && current_user.is_group_admin?(group) && !group.next_steps_completed?
  end

  def members_pending_count(group)
    if group.pending_invitations.count > 0
      t(:number_pending, pending: group.pending_invitations.count)
    else
      ""
    end
  end
end
