module GroupsHelper
  def css_for_privacy_link(group, link)
    current_privacy_setting = String(group.viewable_by)
    return "icon-ok" if link == current_privacy_setting
  end

  def display_subgroups_block?(group)
    group.parent.nil? && (group.subgroups.present? || (current_user && group.users_include?(current_user)))
  end

  def show_next_steps?(group)
    user_signed_in? && current_user.is_group_admin?(group) && !group.next_steps_completed? && @group.is_top_level?
  end

  def pending_membership_requests_count(group)
    if group.pending_membership_requests.count > 0
      t(:number_pending, pending: group.pending_membership_requests.count)
    else
      ""
    end
  end

  def members_pending_count(group)
    if group.pending_invitations.count > 0
      t(:and_number_pending, pending: group.pending_invitations.count)
    else
      ""
    end
  end

  # sorry, not gonna bother refactoring this right now (Jon)
  def request_membership_button(group)
    if visitor?
      if group.is_a_parent?
        request_membership_icon_button(group)
      else
        disabled_request_membership_button(group)
      end
    else
      return if group.users_include?(current_user)
      membership_request = group.membership_requests.where(requestor_id: current_user.id, response: nil).first
      if membership_request.present?
        cancel_membership_request_button(membership_request)
      else
        if group.is_a_parent?
          request_membership_icon_button(group)
        else
          if group.user_is_a_parent_member?(current_user)
            request_membership_icon_button(group)
          else
            disabled_request_membership_button(group)
          end
        end
      end
    end
  end

  def disabled_request_membership_button(group)
    request_membership_icon_button(group, href: "#", class: "btn-info disabled tooltip-top",
                                   id: 'request-membership-disabled',
                                   title: "You must be a member of the parent group before you can join this subgroup.")
  end

  def cancel_membership_request_button(membership_request)
    icon_button(href: cancel_membership_request_path(membership_request),
                method: 'delete',
                text: t(:cancel_membership_request),
                icon: '/assets/group-dark.png',
                id: 'membership-requested',
                class: 'btn-grey',
                'data-confirm' => t(:confirm_remove_membership_request))
  end

  def request_membership_icon_button(group, params={})
    old_params = { href: new_group_membership_request_path(group),
                   text: t(:request_membership),
                   icon: '/assets/group.png',
                   id: 'request-membership',
                   class: 'btn-info' }
    new_params = old_params.merge(params)
    icon_button(new_params)
  end
end
