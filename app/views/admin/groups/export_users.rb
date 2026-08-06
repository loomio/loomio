# frozen_string_literal: true

class Views::Admin::Groups::ExportUsers < Views::Admin::Layout
  def initialize
    super(title: "Export users")
  end

  def view_template
    page_header("Export users")
    form_with(url: export_users_report_admin_groups_path, method: :get, class: "admin-form") do
      div(class: "admin-field") do
        label(for: "group_ids") { "Group IDs separated by spaces" }
        input(id: "group_ids", name: "group_ids", required: true)
      end
      label(class: "admin-checkbox") do
        input(type: "checkbox", name: "coordinators", value: "1")
        span { "Group admins only" }
      end
      button(type: "submit", class: "admin-button") { "Show users" }
    end
  end
end
