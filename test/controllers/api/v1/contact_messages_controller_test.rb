require "test_helper"

class Api::V1::ContactMessagesControllerTest < ActionController::TestCase
  include ActionMailer::TestHelper

  setup do
    @show_contact_previous = ENV["FEATURES_SHOW_CONTACT"]
    ENV.delete("FEATURES_SHOW_CONTACT")
    @message = {
      name: "Support visitor",
      email: "visitor@example.org",
      subject: "Help with Loomio",
      message: "How can I find my group?"
    }
  end

  teardown do
    ENV["FEATURES_SHOW_CONTACT"] = @show_contact_previous
  end

  { signed_out: nil, member: :user, group_admin: :admin, instance_admin: :server_admin }.each do |role, fixture|
    test "#{role} cannot submit a contact message when the form is disabled" do
      sign_in users(fixture) if fixture

      refute AppConfig.app_features.fetch(:show_contact)
      assert_no_enqueued_emails do
        post :create, params: { contact_message: @message }, format: :json
      end

      assert_response :forbidden
    end
  end

  test "an empty contact setting disables the form and backend" do
    ENV["FEATURES_SHOW_CONTACT"] = ""

    refute AppConfig.app_features.fetch(:show_contact)
    assert_no_enqueued_emails do
      post :create, params: { contact_message: @message }, format: :json
    end

    assert_response :forbidden
  end

  test "header injection probes cannot queue mail when the form is disabled" do
    @message[:name] = "Visitor\r\nBcc: probe@example.org"
    @message[:subject] = "Help\r\nBcc: probe@example.org"

    assert_no_enqueued_emails do
      post :create, params: { contact_message: @message }, format: :json
    end

    assert_response :forbidden
  end

  test "a signed-out visitor can submit when the contact setting is present" do
    ENV["FEATURES_SHOW_CONTACT"] = "1"

    assert_enqueued_email_with ContactMailer, :contact_message, args: mail_args do
      post :create, params: { contact_message: @message }, format: :json
    end

    assert_response :success
  end

  test "zero and false setting values still enable contact submissions" do
    %w[0 false].each do |value|
      ENV["FEATURES_SHOW_CONTACT"] = value

      assert_equal true, AppConfig.app_features.fetch(:show_contact)
      assert_enqueued_email_with ContactMailer, :contact_message, args: mail_args do
        post :create, params: { contact_message: @message }, format: :json
      end

      assert_response :success
    end
  end

  test "a signed-in visitor can submit when the form is enabled" do
    ENV["FEATURES_SHOW_CONTACT"] = "1"
    user = users(:user)
    sign_in user

    assert_enqueued_email_with ContactMailer, :contact_message, args: mail_args(user_id: user.id) do
      post :create, params: { contact_message: @message }, format: :json
    end

    assert_response :success
  end

  test "invalid contact email addresses do not queue mail when the form is enabled" do
    ENV["FEATURES_SHOW_CONTACT"] = "1"
    @message[:email] = "invalid-email"

    assert_no_enqueued_emails do
      post :create, params: { contact_message: @message }, format: :json
    end

    assert_response :unprocessable_entity
    assert response.parsed_body.fetch("errors").key?("email")
  end

  private

  def mail_args(**details)
    [
      @message[:name], @message[:email], @message[:subject], @message[:message],
      { site: ENV["CANONICAL_HOST"], form_type: "Support" }.merge(details)
    ]
  end
end
