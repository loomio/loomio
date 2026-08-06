# frozen_string_literal: true

class Views::Admin::Groups::Edit < Views::Admin::Layout
  def initialize(group:)
    super(title: "Edit #{group.name}")
    @group = group
  end

  def view_template
    page_header("Edit #{@group.name}")
    form_with(model: @group, url: admin_group_path(@group), method: :put, class: "admin-form") do |form|
      field(form, :admin_tags, placeholder: "Tags separated by spaces")
      field(form, :parent_id, type: :number_field)
      field(form, :handle)
      field(form, :subscription_id, type: :number_field)
      checkbox_field(form, :is_visible_to_public, label: "Visible to public")
      checkbox_field(form, :is_visible_to_parent_members, label: "Visible to parent members") if @group.parent_id
      checkbox_field(form, :parent_members_can_see_discussions, label: "Parent members can see private threads") if @group.parent_id
      div(class: "admin-field") do
        form.label(:membership_granted_upon)
        form.select(:membership_granted_upon, %w[request approval invitation])
      end
      form.submit("Save group", class: "admin-button")
    end
  end
end
