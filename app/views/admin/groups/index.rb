# frozen_string_literal: true

class Views::Admin::Groups::Index < Views::Admin::Layout
  def initialize(groups:, pagination:, filters:)
    super(title: "Groups")
    @groups = groups
    @pagination = pagination
    @filters = filters
  end

  def view_template
    page_header("Groups", action_label: "Import group", action_path: import_admin_groups_path)
    render_filters
    form_with(url: delete_spam_admin_groups_path, method: :post, data: { confirm: "Schedule the selected trial groups and their creators for deletion?" }) do
      div(class: "admin-table-wrap") do
        table(class: "admin-table") do
          thead do
            tr do
              th { "Select" }
              th { "ID" }
              th { "Name" }
              th { "Privacy" }
              th { "Members" }
              th { "Discussions" }
              th { "Created" }
              th { "Archived" }
              th { "Actions" }
            end
          end
          tbody do
            @groups.each do |group|
              tr do
                td { input(type: "checkbox", name: "group_ids[]", value: group.id, aria: { label: "Select #{group.name}" }) }
                td { group.id }
                td { link_to group.full_name, admin_group_path(group) }
                td { group.group_privacy }
                td { group.memberships_count }
                td { group.discussions_count }
                td { group.created_at.to_date.to_s }
                td { value(group.archived_at&.to_date) }
                td { link_to "Edit", edit_admin_group_path(group) }
              end
            end
          end
        end
      end
      button(type: "submit", class: "admin-button admin-button--danger") { "Delete selected spam groups" }
    end
    pagination_links(@pagination, @filters)
  end

  private

  def render_filters
    form_with(url: admin_groups_path, method: :get, class: "admin-filter-bar") do |form|
      div(class: "admin-filter-bar__search") do
        form.label(:search, "Search groups")
        form.search_field(:search, value: @filters[:search], placeholder: "Name, handle, or description")
      end
      field(form, :memberships_min, type: :number_field, value: @filters[:memberships_min], min: 0)
      field(form, :created_from, type: :date_field, value: @filters[:created_from])
      field(form, :created_to, type: :date_field, value: @filters[:created_to])
      label(class: "admin-checkbox") { input(type: "checkbox", name: "parents_only", value: "1", checked: @filters[:parents_only] == "1"); span { "Parent groups" } }
      label(class: "admin-checkbox") { input(type: "checkbox", name: "not_demo", value: "1", checked: @filters[:not_demo] == "1"); span { "Exclude demos" } }
      form.submit("Search", class: "admin-button")
      link_to "Clear", admin_groups_path, class: "admin-button admin-button--secondary"
    end
  end
end
