# frozen_string_literal: true

class Views::Groups::Export < Views::Application::Component
  def initialize(exporter:)
    @exporter = exporter
  end

  def view_template
    h1 { plain "Export for #{@exporter.group.full_name}" }
    render Views::Groups::ExportTable.new(name: "Groups", records: @exporter.groups, fields: @exporter.group_fields, exporter: @exporter)
    render Views::Groups::ExportTable.new(name: "Memberships", records: @exporter.memberships, fields: @exporter.membership_fields, exporter: @exporter)
    render Views::Groups::ExportTable.new(name: "Discussions", records: @exporter.discussions, fields: @exporter.discussion_fields, exporter: @exporter)
    render Views::Groups::ExportTable.new(name: "Comments", records: @exporter.comments, fields: @exporter.comment_fields, exporter: @exporter)
    render Views::Groups::ExportTable.new(name: "Polls", records: @exporter.polls, fields: @exporter.poll_fields, exporter: @exporter)
    render Views::Groups::ExportTable.new(name: "Stances", records: @exporter.stances, fields: @exporter.stance_fields, exporter: @exporter)
  end
end
