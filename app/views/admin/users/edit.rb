# frozen_string_literal: true

class Views::Admin::Users::Edit < Views::Admin::Layout
  def initialize(user:)
    super(title: "Edit #{user.name}")
    @user = user
  end

  def view_template
    page_header("Edit #{@user.name}")
    form_with(model: @user, url: admin_user_path(@user), method: :put, class: "admin-form") do |form|
      render_errors if @user.errors.any?
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

  private

  def render_errors
    div(class: "admin-form-errors", role: "alert") do
      strong { "User could not be updated" }
      ul do
        @user.errors.full_messages.each { |message| li { message } }
      end
      render_email_collision_guidance if @user.errors.of_kind?(:email, :taken)
    end
  end

  def render_email_collision_guidance
    p do
      plain "That email belongs to another account. To combine the accounts, use "
      link_to "Merge into another account", admin_user_path(@user, anchor: "merge-user")
      plain " on this user's page."
    end
  end
end
