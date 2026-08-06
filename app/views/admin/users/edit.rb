# frozen_string_literal: true

class Views::Admin::Users::Edit < Views::Admin::Layout
  def initialize(user:)
    super(title: "Edit #{user.name}")
    @user = user
  end

  def view_template
    page_header("Edit #{@user.name}")
    form_with(model: @user, url: admin_user_path(@user), method: :put, class: "admin-form") do |form|
      field(form, :name)
      field(form, :email, type: :email_field)
      field(form, :username)
      field(form, :complaints_count, type: :number_field, min: 0)
      field(form, :bounces_count, type: :number_field, min: 0)
      checkbox_field(form, :is_admin, label: "System admin")
      checkbox_field(form, :bot, label: "Bot account")
      form.submit("Save user", class: "admin-button")
    end
  end
end
