# frozen_string_literal: true

class Views::Admin::Groups::Show < Views::Admin::Layout
  def initialize(group:)
    super(title: group.name)
    @group = group
  end

  def view_template
    page_header(@group.full_name, action_label: "Edit group", action_path: edit_admin_group_path(@group))
    render_stats
    render_subscription if defined?(Subscription) && @group.subscription_id
    render_subgroups
    render_members
    panel("Group attributes") { definition_list(@group, group_attribute_keys) }
    render_operations
  end

  private

  def render_stats
    panel("Group stats") do
      div(class: "admin-stats") do
        stat("Invited members", @group.org_members_count)
        stat("Accepted members", @group.org_accepted_members_count)
        stat("Subgroups", @group.subgroups.count)
        stat("Discussions", @group.discussions_count)
      end
      p { "Tags: #{value(@group.admin_tags)}" }
      p { "Description: #{value(@group.description)}" }
    end
  end

  def stat(label, number)
    div do
      strong { number }
      span { label }
    end
  end

  def render_subscription
    subscription = Subscription.for(@group)
    return unless subscription

    panel("Subscription") do
      p { link_to "Subscription ##{subscription.id}", admin_subscription_path(subscription) }
      p { "#{subscription.plan} · #{subscription.state} · expires #{value(subscription.expires_at)}" }
    end
  end

  def render_subgroups
    panel("Subgroups") do
      ul(class: "admin-list") do
        @group.subgroups.order(memberships_count: :desc).each do |group|
          li { link_to "#{group.name} (#{group.memberships_count} members)", admin_group_path(group) }
        end
      end
    end
  end

  def render_members
    panel("Members") do
      div(class: "admin-table-wrap") do
        table(class: "admin-table admin-table--compact") do
          thead { tr { %w[Name Email Admin Joined Revoked Action].each { |heading| th { heading } } } }
          tbody do
            @group.all_memberships.includes(:user).order(created_at: :desc).each do |membership|
              next unless membership.user
              tr do
                td { link_to membership.user.name, admin_user_path(membership.user) }
                td { membership.user.email }
                td { membership.admin? ? "Yes" : "No" }
                td { value(membership.accepted_at&.to_date) }
                td { value(membership.revoked_at&.to_date) }
                td do
                  if membership.admin?
                    button_to "Remove admin", remove_admin_admin_groups_path(membership_id: membership.id), method: :post, class: "admin-link-button", form: { data: { confirm: "Remove admin access from #{membership.user.name}?" } }
                  else
                    button_to "Add admin", add_admin_admin_groups_path(membership_id: membership.id), method: :post, class: "admin-link-button", form: { data: { confirm: "Give admin access to #{membership.user.name}?" } }
                  end
                end
              end
            end
          end
        end
      end
    end
  end

  def render_operations
    panel("Operations", class_name: "admin-panel--operations") do
      div(class: "admin-operation-list") do
        operation_form("Parent group ID or key", move_admin_group_path(@group), "parent_id", @group.parent_id, "Move group")
        operation_form("Change handle", handle_admin_group_path(@group), "handle", @group.handle, "Change handle")
        if @group.archived_at
          button_to "Unarchive group", unarchive_admin_group_path(@group), method: :post, class: "admin-button"
        else
          button_to "Archive group", archive_admin_group_path(@group), method: :post, class: "admin-button admin-button--secondary", form: { data: { confirm: "Archive #{@group.name} and all of its subgroups? Their content will be retained, but the groups will be hidden from normal use until they are unarchived." } }
        end
        button_to "Export group", export_group_admin_group_path(@group), method: :post, class: "admin-button admin-button--secondary"
        button_to "Delete group", delete_group_admin_group_path(@group), method: :post, class: "admin-button admin-button--danger", form: { data: { confirm: "Delete #{@group.name} and all of its subgroups? This permanently deletes their memberships and membership requests, topics and discussions, polls, votes and outcomes, topic_items and notifications, templates, chatbots, handle redirects, reactions, and file attachments. User accounts and subscriptions are not deleted. This cannot be undone." } }
      end
    end
  end

  def operation_form(title, url, name, current_value, submit_label)
    form_with(url: url, method: :post, class: "admin-inline-form") do
      label(for: "#{name}-#{@group.id}") { title }
      input(id: "#{name}-#{@group.id}", name: name, value: current_value)
      button(type: "submit", class: "admin-button") { submit_label }
    end
  end

  def group_attribute_keys
    %i[id key name handle full_name created_at updated_at parent_id creator_id archived_at memberships_count admin_memberships_count discussions_count membership_granted_upon is_visible_to_public is_visible_to_parent_members parent_members_can_see_discussions discussion_privacy_options members_can_add_members members_can_edit_discussions members_can_edit_comments members_can_raise_motions members_can_start_discussions members_can_create_subgroups members_can_create_tags subscription_id theme_id]
  end
end
