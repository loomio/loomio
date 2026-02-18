require 'test_helper'

class Dev::DiscussionMailerTest < ActionController::TestCase
  tests Dev::NightwatchController

  setup do
    Rails.application.routes.default_url_options[:host] = "https://loomio.test"
  end

  private

  def parsed_body
    Nokogiri::HTML(response.body)
  end

  def assert_text_no_tags(selector, val)
    text = parsed_body.css(selector).text
    assert_includes text, val, "Expected text in '#{selector}' to include '#{val}', got: #{text.truncate(200)}"
  end

  public

  test "discussion_created" do
    get :setup_discussion_mailer_discussion_created_email
    assert_response :success
    assert_text_no_tags('.base-mailer__event-headline', "started a discussion")
    assert_text_no_tags('.thread-mailer__body', "A description for this discussion. Should this be rich?")
  end

  test "discussion_announced" do
    get :setup_discussion_mailer_discussion_announced_email
    assert_response :success
    assert_text_no_tags('.base-mailer__event-headline', "invited you to a discussion")
    assert_text_no_tags('.thread-mailer__body', "A description for this discussion. Should this be rich?")
  end

  test "invitation_created" do
    get :setup_discussion_mailer_invitation_created_email
    assert_response :success
    assert_text_no_tags('.base-mailer__event-headline', "invited you to a discussion")
    assert_text_no_tags('.thread-mailer__body', "A description for this discussion. Should this be rich?")
  end

  test "new_comment" do
    get :setup_discussion_mailer_new_comment_email
    assert_response :success
    assert_text_no_tags('.base-mailer__event-headline', "Jennifer Grey commented in: What star sign are you?")
    assert_text_no_tags('.thread-mailer__body', "hello patrick.")
  end

  test "user_mentioned" do
    get :setup_discussion_mailer_user_mentioned_email
    assert_response :success
    assert_text_no_tags('.base-mailer__event-headline', "Jennifer Grey mentioned you")
    assert_text_no_tags('.thread-mailer__body', "hey @patrickswayze wanna dance?")
  end

  test "comment_replied_to" do
    get :setup_discussion_mailer_comment_replied_to_email
    assert_response :success
    assert_text_no_tags('.base-mailer__event-headline', "Patrick Swayze replied to you")
    assert_text_no_tags('.thread-mailer__body', "why, hello there @jennifergrey")
  end
end
