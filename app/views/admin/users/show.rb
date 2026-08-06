# frozen_string_literal: true

class Views::Admin::Users::Show < Views::Admin::Layout
  ACCOUNT_ATTRIBUTE_KEYS = %i[
    id name username email locale is_admin bot email_verified memberships_count
    deactivated_at deactivator_id
  ].freeze

  DIAGNOSTIC_ATTRIBUTE_KEYS = %i[
    created_at updated_at sign_in_count current_sign_in_at last_sign_in_at last_seen_at
    failed_attempts locked_at complaints_count bounces_count legal_accepted_at
    time_zone date_time_pref
  ].freeze

  def initialize(user:)
    super(title: user.name)
    @user = user
  end

  def view_template
    page_header(@user.name, action_label: "Edit user", action_path: edit_admin_user_path(@user))
    panel("Account") { definition_list(@user, ACCOUNT_ATTRIBUTE_KEYS) }
    panel("Diagnostics") { definition_list(@user, DIAGNOSTIC_ATTRIBUTE_KEYS) }
    render_memberships
    render_identities
    render_notifications
    render_operations
  end

  private

  def render_memberships
    memberships = @user.all_memberships.includes(:group).order(:id).to_a
    active_memberships, revoked_memberships = memberships.partition { |membership| membership.revoked_at.blank? }

    panel("Memberships") do
      render_membership_table(active_memberships)
      if revoked_memberships.any?
        details(class: "admin-disclosure") do
          summary { "Revoked memberships (#{revoked_memberships.size})" }
          render_membership_table(revoked_memberships)
        end
      end
    end
  end

  def render_membership_table(memberships)
    div(class: "admin-table-wrap") do
      table(class: "admin-table") do
        thead { tr { %w[ID Group Volume Admin Accepted Revoked].each { |heading| th { heading } } } }
        tbody do
          memberships.each do |membership|
            tr do
              td { membership.id }
              td do
                if membership.group
                  link_to membership.group.full_name, admin_group_path(membership.group)
                elsif membership.group_id
                  plain "Missing group ##{membership.group_id}"
                else
                  plain "Missing group"
                end
              end
              td { value(membership.volume) }
              td { membership.admin? ? "Yes" : "No" }
              td { value(membership.accepted_at&.to_date) }
              td { value(membership.revoked_at&.to_date) }
            end
          end
        end
      end
    end
  end

  def render_identities
    panel("Identities") do
      table(class: "admin-table") do
        thead { tr { %w[Type UID Name Email Action].each { |heading| th { heading } } } }
        tbody do
          @user.identities.each do |identity|
            tr do
              td { identity.identity_type }
              td { identity.uid }
              td { value(identity.name) }
              td { value(identity.email) }
              td do
                button_to "Delete", delete_identity_admin_user_path(@user, identity_id: identity.id), method: :post, class: "admin-link-button admin-link-button--danger", form: { data: { confirm: "Delete this #{identity.identity_type} identity?" } }
              end
            end
          end
        end
      end
    end
  end

  def render_notifications
    panel("Recent notifications") do
      ul(class: "admin-list") do
        Notification.includes(:event).where(user_id: @user.id).order(id: :desc).limit(30).each do |notification|
          li { "##{notification.id} · #{value(notification.event&.kind)} · #{notification.created_at}" }
        end
      end
    end
  end

  def render_operations
    panel("Operations", class_name: "admin-panel--operations") do
      div(class: "admin-operation-list") do
        button_to "Sign in as #{@user.name}", login_as_admin_user_path(@user), method: :post, class: "admin-button", form: { data: { confirm: "Create a one-time sign-in link for #{@user.email}?" } }
        if @user.deactivated_at
          button_to "Reactivate user", reactivate_admin_user_path(@user), method: :put, class: "admin-button", form: { data: { confirm: "Reactivate #{@user.email}?" } }
        else
          button_to "Deactivate user", deactivate_admin_user_path(@user), method: :put, class: "admin-button admin-button--secondary", form: { data: { confirm: "Deactivate #{@user.email}?" } }
        end
        button_to "Redact user", redact_admin_user_path(@user), method: :put, class: "admin-button admin-button--danger", form: { data: { confirm: "Permanently redact #{@user.email}?" } } if @user.email
        button_to "Delete spam user", delete_spam_admin_user_path(@user), method: :delete, class: "admin-button admin-button--danger", form: { data: { confirm: "Delete #{@user.email} and content they authored?" } }
        form_with(url: merge_admin_user_path(@user), method: :post, class: "admin-inline-form", data: { confirm: "Merge this account into the destination account?" }) do
          label(for: "destination-email") { "Merge into another account" }
          input(id: "destination-email", name: "destination_email", type: "email", required: true, placeholder: "Destination email")
          button(type: "submit", class: "admin-button admin-button--danger") { "Merge user" }
        end
      end
    end
  end
end
