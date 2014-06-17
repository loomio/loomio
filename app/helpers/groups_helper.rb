module GroupsHelper
  def group_visibilty_options(group)
    options = []

    unless group.is_subgroup_of_hidden_parent?
      options << [t(:'group_form.visible_to.public_html'), 'public']
    end

    if group.is_subgroup?
      options << [t(:'group_form.visible_to.parent_members_html', parent_group_name: group.parent.name ),
                  "parent_members"]
    end

    options << [t(:'group_form.visible_to.members_html'), "members"]

    options
  end

  def group_joining_options(group)
    if group.is_subgroup_of_hidden_parent?
      [[t(:'group_form.membership_granted_upon.hidden_parent.request_html',
          parent_group_name: group.parent.name),
        'request'],
       [t(:'group_form.membership_granted_upon.hidden_parent.approval_html',
          parent_group_name: group.parent.name),
        'approval'],
       [t(:'group_form.membership_granted_upon.invitation_html'),
        'invitation']]
    else
      [[t(:'group_form.membership_granted_upon.request_html'), 'request'],
       [t(:'group_form.membership_granted_upon.approval_html'), 'approval'],
       [t(:'group_form.membership_granted_upon.invitation_html'), 'invitation']]
    end
  end

  def show_next_steps?(group)
    user_signed_in? && current_user.is_group_admin?(group) && !group.next_steps_completed? && @group.is_parent?
  end

  def show_subscription_prompt?(group)
    user_signed_in? && current_user.is_group_admin?(group) &&
      ( group.created_at < 1.month.ago ) &&
      !group.has_subscription_plan? &&
      !group.has_manual_subscription? &&
      !group.is_subgroup?
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

  def join_group_button(group, args = {})
    if user_can_join_group?(current_user_or_visitor, group)
      case group.membership_granted_upon
      when 'request'
        icon_button({href: join_group_path(group),
                     method: :post,
                     text: t(:join_group_btn)}.merge(args))
      when 'approval'
        if group.pending_membership_request_for(current_user_or_visitor)
          membership_request = group.membership_requests.pending.where(requestor_id: current_user_or_visitor).first
          cancel_membership_request_button(membership_request)
        else
          request_membership_icon_button(group)
        end
      end
    end
  end

  def user_can_join_group?(user, group)
    return true if user.is_logged_out?
    # need to say No if any memberships, suspended or otherwise
    Membership.where(user_id: user.id, group_id: group.id).blank?
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
                   text: t(:ask_to_join_group),
                   icon: nil,
                   id: 'request-membership',
                   class: 'btn-info' }
    new_params = old_params.merge(params)
    icon_button(new_params)
  end

  def label_and_description(label, description)
    render('groups/label_and_description', label: label, description: description)
  end

  def user_sees_private_discussions_message?(user, group)
    group.privacy == 'private' &&
    group.members.exclude?(user) &&
    group.discussions.where('private = ?', false).empty?
  end

  def use_parent_if_blank(group, method)
    if group.is_subgroup? && group.send(method).blank?
      group.parent.send(method)
    else
      group.send(method)
    end
  end
end
