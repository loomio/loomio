require 'test_helper'

class Dev::AuthMailerTest < ActionController::TestCase
  tests Dev::NightwatchController

  setup do
    Rails.application.routes.default_url_options[:host] = "https://loomio.test"
  end

  test "group invitation renders description line breaks as HTML" do
    get :setup_invitation_email_to_visitor

    assert_response :success
    description = Nokogiri::HTML(response.body).at_css('.group-mailer__description')
    assert description
    assert_includes description.text, "The best place for dancing shoes"
    refute_includes description.text, "<br>"
  end
end
