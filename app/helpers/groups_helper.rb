module GroupsHelper

  def css_for_privacy_link(group, link)
    current_privacy_setting = String(group.privacy)
    return "icon-ok" if link == current_privacy_setting
  end

  def display_subgroups_block?(group)
    group.parent.nil? && (group.subgroups.present? || (current_user && group.users_include?(current_user)))
  end

  def show_next_steps?(group)
    user_signed_in? && current_user.is_group_admin?(group) && !group.next_steps_completed? && @group.is_top_level?
  end

  def show_subscription_prompt?(group)
    user_signed_in? && current_user.is_group_admin?(group) &&
      ( group.created_at < 1.month.ago ) &&
      !group.has_subscription_plan? &&
      !group.has_manual_subscription? &&
      !group.is_a_subgroup? &&
      ( I18n.locale == :en )
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

  def request_membership_button(group)
    if visitor?
      request_membership_icon_button(group)
    else
      return if group.users_include?(current_user)

      membership_request = group.membership_requests.pending.requested_by(current_user).first
      if membership_request.present?
        cancel_membership_request_button(membership_request)
      else
        request_membership_icon_button(group)
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
    old_params = { href: group_ask_to_join_path(group),
                   text: t(:ask_to_join_group),
                   icon: nil,
                   id: 'request-membership',
                   class: 'btn-info' }
    new_params = old_params.merge(params)
    icon_button(new_params)
  end

  def group_privacy_options(group)
    privacy_settings = []
    Group::PRIVACY_CATEGORIES.each do |privacy_setting|
      header = t "simple_form.labels.group.privacy_#{privacy_setting}_header"
      description = t "simple_form.labels.group.privacy_#{privacy_setting}_description"

      if privacy_setting != 'hidden' && group.is_a_subgroup? && group.parent.privacy == 'hidden'
        disabled_class = 'disabled'
        text_color = '#CCCCCC'
      else
        disabled_class = ''
        text_color = ''
      end
      privacy_settings << ["<span class='privacy-setting-header #{disabled_class}'>#{header}</strong><br />
                            <p style='color:#{text_color}'>#{description}</p>".html_safe, privacy_setting.to_sym]
    end
    privacy_settings
  end

  def group_privacy_options_disabled(group)
    if group.is_a_subgroup? && group.parent.privacy == 'hidden'
      ['public', 'private']
    else
      []
    end
  end

  def group_viewable_by_parent_label(group)
    t(:'simple_form.labels.group.viewable_by_parent_members_header', group: group.parent.name)
  end

  def group_invitable_by_options(group)
    [[t('simple_form.labels.group.members_invitable_by_coordinators'), :admins],
     [t('simple_form.labels.group.members_invitable_by_members'), :members]]
  end

  def user_sees_private_discussions_message?(user, group)
    group.privacy == 'private' &&
    group.members.exclude?(user) &&
    group.discussions.where('private = ?', false).empty?
  end

end
