# frozen_string_literal: true

class Views::Admin::Users::Index < Views::Admin::Layout
  def initialize(users:, pagination:, filters:)
    super(title: "Users")
    @users = users
    @pagination = pagination
    @filters = filters
  end

  def view_template
    page_header("Users")
    render_filters
    form_with(url: bulk_action_admin_users_path, method: :post, data: { bulk_user_action: true }) do
      div(class: "admin-table-wrap") do
        table(class: "admin-table") do
          thead do
            tr do
              th { input(type: "checkbox", data: { select_all: "user_ids[]" }, aria: { label: "Select all users on this page" }) }
              ["Name", "Email", "Created", "Last sign-in", "Groups", "Deactivated", "Verified", "Locale", "Timezone"].each { |heading| th { heading } }
            end
          end
          tbody do
            @users.each do |user|
              tr do
                td { input(type: "checkbox", name: "user_ids[]", value: user.id, aria: { label: "Select #{user.name.presence || user.email}" }) }
                td { link_to(user.name.presence || user.email, admin_user_path(user)) }
                td { user.email }
                td { value(user.created_at&.to_date) }
                td { value(user.last_sign_in_at&.to_date) }
                td { user.memberships_count }
                td { value(user.deactivated_at&.to_date) }
                td { user.email_verified? ? "Yes" : "No" }
                td { value(user.detected_locale || user.locale) }
                td { value(user.time_zone) }
              end
            end
          end
        end
      end
      div(class: "admin-bulk-actions") do
        fieldset do
          legend { "Action for selected users" }
          label(class: "admin-bulk-action") do
            input(type: "radio", name: "operation", value: "deactivate", required: true, data: { confirm: "Deactivate the selected users? They will no longer be able to sign in." })
            span do
              strong { "Deactivate" }
              small { "Blocks sign-in and revokes group memberships. Keeps the account, profile and authored content, and can be reversed." }
            end
          end
          label(class: "admin-bulk-action") do
            input(type: "radio", name: "operation", value: "redact", required: true, data: { confirm: "Permanently redact the selected users? Their personal information will be removed. This cannot be undone." })
            span do
              strong { "Redact" }
              small { "Deactivates the account, revokes memberships and permanently removes personal and sign-in data. Keeps authored content without the person's identity." }
            end
          end
          label(class: "admin-bulk-action") do
            input(type: "radio", name: "operation", value: "delete_spam", required: true, data: { confirm: "Destroy the selected users and dependent content they authored? This cannot be undone." })
            span do
              strong { "Destroy / delete as spam" }
              small { "Permanently deletes the account and dependent records, including authored content. Use this for spam accounts only." }
            end
          end
        end
        button(type: "submit", class: "admin-button admin-button--danger") { "Apply to selected users" }
      end
    end
    pagination_links(@pagination, @filters)
  end

  private

  def render_filters
    form_with(url: admin_users_path, method: :get, class: "admin-filter-bar") do |form|
      div(class: "admin-filter-bar__search") do
        form.label(:search, "Search users")
        form.search_field(:search, value: @filters[:search], placeholder: "Name, username, or email")
      end
      div(class: "admin-field") do
        form.label(:locale)
        form.text_field(:locale, value: @filters[:locale], list: "admin-user-locales")
        datalist(id: "admin-user-locales") do
          I18n.available_locales.map(&:to_s).sort.each { |locale| option(value: locale) }
        end
      end
      field(form, :created_from, type: :date_field, value: @filters[:created_from])
      field(form, :created_to, type: :date_field, value: @filters[:created_to])
      div(class: "admin-field") do
        form.label(:email_verified)
        form.select(:email_verified, [["Any", ""], ["Verified", "true"], ["Not verified", "false"]], selected: @filters[:email_verified])
      end
      label(class: "admin-checkbox") { input(type: "checkbox", name: "coordinators", value: "1", checked: @filters[:coordinators] == "1"); span { "Group admins" } }
      label(class: "admin-checkbox") { input(type: "checkbox", name: "deactivated", value: "1", checked: @filters[:deactivated] == "1"); span { "Deactivated" } }
      form.submit("Search", class: "admin-button")
      link_to "Clear", admin_users_path, class: "admin-button admin-button--secondary"
    end
  end
end
