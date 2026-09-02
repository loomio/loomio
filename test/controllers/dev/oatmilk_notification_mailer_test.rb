require 'test_helper'

class Dev::OatmilkNotificationMailerTest < ActionController::TestCase
  tests Dev::NightwatchController

  setup do
    Rails.application.routes.default_url_options[:host] = "https://loomio.test"
  end

  test "proposal invitation email renders the proposal and voting form" do
    get :setup_manual_oatmilk_proposal_invitation_email

    assert_response :success
    assert parsed_body.css('.error').empty?
    assert_text_in 'main', 'Run a six-week returnable bottle trial'
    assert_text_in 'main', 'Please vote'
  end

  test "proposal outcome email renders the outcome, results, and responses" do
    get :setup_manual_oatmilk_proposal_outcome_email

    assert_response :success
    assert parsed_body.css('.error').empty?
    assert_text_in 'main', 'Run a six-week returnable bottle trial'
    assert_text_in 'main', 'Run the six-week bottle trial with three cafes'
    assert_text_in 'main', 'Results'
    assert_text_in 'main', 'Samira Patel'
    assert_text_in 'main', 'Alex Morgan'
  end

  private

  def parsed_body
    @parsed_body ||= Nokogiri::HTML(response.body)
  end

  def assert_text_in(selector, value)
    text = parsed_body.css(selector).text
    assert_includes text, value, "Expected text in '#{selector}' to include '#{value}', got: #{text.truncate(200)}"
  end

  def assert_element(selector)
    assert parsed_body.css(selector).any?, "Expected element '#{selector}' to exist"
  end
end
