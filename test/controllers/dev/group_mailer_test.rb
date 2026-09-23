require "test_helper"

class Dev::GroupMailerTest < ActionController::TestCase
  tests Dev::NightwatchController

  test "expired trial deletion warning preview" do
    get :setup_group_mailer_expired_trial_deletion_warning

    assert_response :success
    text = Nokogiri::HTML(response.body).css("main").text
    assert_includes text, "trial expired 60 days ago"
    assert_includes text, "it is not too late to restart"
    assert_includes text, "request a trial extension, upgrade to a paid subscription"
  end

  test "coordinator requested deletion warning preview" do
    get :setup_group_mailer_deletion_warning

    assert_response :success
    text = Nokogiri::HTML(response.body).css("main").text
    assert_includes text, "was scheduled for deletion by Jennifer Grey"
    assert_includes text, "reply to this email within 90 days"
  end
end
