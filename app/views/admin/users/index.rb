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
    div(class: "admin-table-wrap") do
      table(class: "admin-table") do
        thead { tr { %w[Name Email Created Last sign-in Groups Deactivated Verified Locale Timezone Actions].each { |heading| th { heading } } } }
        tbody do
          @users.each do |user|
            tr do
              td { link_to user.name, admin_user_path(user) }
              td { user.email }
              td { value(user.created_at&.to_date) }
              td { value(user.last_sign_in_at&.to_date) }
              td { user.memberships_count }
              td { value(user.deactivated_at&.to_date) }
              td { user.email_verified? ? "Yes" : "No" }
              td { value(user.detected_locale || user.locale) }
              td { value(user.time_zone) }
              td { link_to "Edit", edit_admin_user_path(user) }
            end
          end
        end
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
