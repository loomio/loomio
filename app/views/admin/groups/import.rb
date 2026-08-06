# frozen_string_literal: true

class Views::Admin::Groups::Import < Views::Admin::Layout
  def initialize
    super(title: "Import group")
  end

  def view_template
    page_header("Import group")
    form_with(url: import_json_admin_groups_path, method: :post, class: "admin-form") do
      div(class: "admin-field") do
        label(for: "url") { "Export URL" }
        input(id: "url", name: "url", type: "url", required: true)
      end
      button(type: "submit", class: "admin-button") { "Start import" }
    end
  end
end
