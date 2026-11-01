# frozen_string_literal: true

class Views::Admin::Dashboard < Views::Admin::Layout
  def initialize(stats:, authentication_stats:)
    super(title: "Dashboard")
    @stats = stats
    @authentication_stats = authentication_stats
  end

  def view_template
    page_header("Dashboard")
    div(class: "admin-stats admin-dashboard-stats") do
      @stats.each do |label, count|
        div do
          strong { count.to_fs(:delimited) }
          span { label }
        end
      end
    end
    h2 { "Sign-in credentials" }
    p { "Current credentials for all users, including deactivated accounts. Recent users signed in at least once in the last 30 days." }
    div(class: "admin-table-wrap") do
      table(class: "admin-table", id: "authentication-stats") do
        thead do
          tr do
            th(scope: "col") { "Users" }
            th(scope: "col") { "Total" }
            th(scope: "col") { "Signed in within 30 days" }
          end
        end
        tbody do
          {
            users: "All users",
            password: "With a password",
            passkey: "With a passkey",
            both: "With both",
            neither: "With neither"
          }.each do |key, label|
            counts = @authentication_stats.fetch(key)
            tr do
              th(scope: "row") { label }
              td { counts.fetch(:total).to_fs(:delimited) }
              td { counts.fetch(:recent).to_fs(:delimited) }
            end
          end
        end
      end
    end
    p { "Password and passkey counts overlap. Each user is counted once per row, even with multiple passkeys. These counts show credentials held now, not the method used to sign in. Users with neither can use email or configured single sign-on options." }
  end
end
