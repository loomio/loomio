# frozen_string_literal: true

class Views::Admin::Groups::ExportUsersReport < Views::Admin::Layout
  def initialize(users:)
    super(title: "Export users report")
    @users = users
  end

  def view_template
    page_header("Users report")
    table(class: "admin-table") do
      thead { tr { %w[Name Email Country].each { |heading| th { heading } } } }
      tbody do
        @users.each do |user|
          tr do
            td { user.name }
            td { user.email }
            td { value(user.country) }
          end
        end
      end
    end
  end
end
