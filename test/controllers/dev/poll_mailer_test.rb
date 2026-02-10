require 'test_helper'

class Dev::PollMailerTest < ActionController::TestCase
  tests Dev::PollsController

  POLL_TYPES = %w[proposal poll dot_vote score count meeting ranked_choice].freeze

  setup do
    Rails.application.routes.default_url_options[:host] = "https://loomio.test"
  end

  private

  def parsed_body
    Nokogiri::HTML(response.body)
  end

  def i18n_params
    {group:      parsed_body.css('.i18n-params .group').text,
     discussion: parsed_body.css('.i18n-params .discussion').text,
     voter:      parsed_body.css('.i18n-params .voter').text,
     poll:       parsed_body.css('.i18n-params .poll').text,
     title:      parsed_body.css('.i18n-params .poll').text,
     actor:      parsed_body.css('.i18n-params .actor').text,
     poll_type:  parsed_body.css('.i18n-params .poll_type').text}
  end

  def assert_text(selector, val)
    html = parsed_body.css(selector).to_s.downcase
    assert_includes html, val.downcase, "Expected '#{selector}' HTML to include '#{val}'"
  end

  def assert_text_no_tags(selector, val)
    text = parsed_body.css(selector).text
    assert_includes text, val, "Expected text in '#{selector}' to include '#{val}'"
  end

  def assert_element(selector)
    assert parsed_body.css(selector).to_s.length > 0, "Expected element '#{selector}' to exist"
  end

  def assert_notification_headline(key)
    html = parsed_body.css('.base-mailer__event-headline').to_s
    assert_includes html, I18n.t(key, **i18n_params), "Expected headline to include i18n key '#{key}'"
  end

  public

  POLL_TYPES.each do |poll_type|
    test "#{poll_type} created email" do
      get :test_poll_scenario, params: {scenario: 'poll_created', poll_type: poll_type, format: 'email'}
      assert_response :success
      assert_text('.base-mailer__event-headline', "Voting has opened")
      assert_notification_headline("notifications.without_title.poll_opened")
      assert_element('.poll-mailer-common-summary')
      assert_text('.poll-mailer__vote', "Please vote")
    end

    test "anonymous #{poll_type} created email" do
      get :test_poll_scenario, params: {scenario: 'poll_created', poll_type: poll_type, anonymous: true, format: 'email'}
      assert_response :success
      assert_notification_headline("notifications.without_title.poll_opened")
      assert_element('.poll-mailer-common-summary')
      assert_text('.poll-mailer__vote', I18n.t("poll_common_action_panel.anonymous"))
      assert_text('.poll-mailer__vote', "Please vote")
    end

    test "#{poll_type} outcome_created email" do
      get :test_poll_scenario, params: {scenario: 'poll_outcome_created', poll_type: poll_type, format: 'email'}
      assert_response :success
      assert_notification_headline("notifications.without_title.outcome_created")
      assert_text('.poll-mailer-common-summary', "Outcome")
      assert_text('.poll-mailer__results-chart', "Results")
      assert_text('.poll-mailer-common-responses', "Responses")
    end

    test "#{poll_type} outcome_review_due email" do
      get :test_poll_scenario, params: {scenario: 'poll_outcome_review_due', poll_type: poll_type, format: 'email'}
      assert_response :success
      assert_notification_headline("notifications.without_title.outcome_review_due")
      assert_text('.poll-mailer-common-summary', "Outcome")
      assert_text('.poll-mailer__results-chart', "Results")
      assert_text('.poll-mailer-common-responses', "Responses")
    end

    test "anonymous #{poll_type} outcome_created email" do
      get :test_poll_scenario, params: {scenario: 'poll_outcome_created', poll_type: poll_type, anonymous: true, format: 'email'}
      assert_response :success
      assert_notification_headline("notifications.without_title.outcome_created")
      assert_text('.poll-mailer-common-summary', "Outcome")
      assert_text('.poll-mailer__results-chart', "Results")
      assert_text('.poll-mailer-common-responses', I18n.t("poll_common_action_panel.anonymous"))
      assert_text('.poll-mailer-common-responses', "Responses")
      assert_text('.poll-mailer-common-responses', "Anonymous")
    end

    test "#{poll_type} stance_created email" do
      get :test_poll_scenario, params: {scenario: 'poll_stance_created', poll_type: poll_type, format: 'email'}
      assert_response :success
      assert_notification_headline("notifications.without_title.stance_created")
      assert_element('.poll-mailer__stance')
    end

    test "anonymous #{poll_type} stance_created email" do
      get :test_poll_scenario, params: {scenario: 'poll_stance_created', poll_type: poll_type, anonymous: true, format: 'email'}
      assert_response :success
      assert_notification_headline("notifications.without_title.stance_created")
      assert_text(".base-mailer__event-headline", "Anonymous")
      assert_element('.poll-mailer__stance')
    end

    test "results_hidden #{poll_type} stance_created email" do
      get :test_poll_scenario, params: {scenario: 'poll_stance_created', poll_type: poll_type, hide_results: 'until_closed', format: 'email'}
      assert_response :success
      assert_notification_headline("notifications.without_title.stance_created")
      assert_element('.poll-mailer__stance')
    end

    test "#{poll_type} poll_closing_soon email" do
      get :test_poll_scenario, params: {scenario: 'poll_closing_soon', poll_type: poll_type, format: 'email'}
      assert_response :success
      assert_notification_headline("notifications.without_title.poll_closing_soon")
      assert_element('.poll-mailer-common-summary')
      assert_text('.poll-mailer__vote', "Please vote")
    end

    test "anonymous #{poll_type} poll_closing_soon email" do
      get :test_poll_scenario, params: {scenario: 'poll_closing_soon', poll_type: poll_type, anonymous: true, format: 'email'}
      assert_response :success
      assert_notification_headline("notifications.without_title.poll_closing_soon")
      assert_element('.poll-mailer-common-summary')
      assert_text('.poll-mailer__vote', "Please vote")
    end

    test "hide_results #{poll_type} poll_closing_soon email" do
      get :test_poll_scenario, params: {scenario: 'poll_closing_soon', poll_type: poll_type, hide_results: 'until_closed', format: 'email'}
      assert_response :success
      assert_notification_headline("notifications.without_title.poll_closing_soon")
      assert_element('.poll-mailer-common-summary')
      assert_text('.poll-mailer__vote', "Please vote")
    end

    test "#{poll_type} poll_closing_soon_author email" do
      get :test_poll_scenario, params: {scenario: 'poll_closing_soon_author', poll_type: poll_type, format: 'email'}
      assert_response :success
      assert_notification_headline("notifications.without_title.poll_closing_soon_author")
      assert_element('.poll-mailer-common-summary')
      assert_text('.poll-mailer__vote', "Please vote")
    end

    test "#{poll_type} poll_user_mentioned_email" do
      get :test_poll_scenario, params: {scenario: 'poll_user_mentioned', poll_type: poll_type, format: 'email'}
      assert_response :success
      assert_notification_headline("notifications.without_title.user_mentioned")
    end

    test "anonymous #{poll_type} poll_user_mentioned_email" do
      get :test_poll_scenario, params: {scenario: 'poll_user_mentioned', anonymous: true, poll_type: poll_type, format: 'email'}
      assert_response :success
      assert_text('.error', "no emails sent")
    end

    test "hidden #{poll_type} poll_user_mentioned_email" do
      get :test_poll_scenario, params: {scenario: 'poll_user_mentioned', hide_results: 'until_closed', poll_type: poll_type, format: 'email'}
      assert_response :success
      assert_text('.error', "no emails sent")
    end

    test "#{poll_type} poll_expired_author_email" do
      get :test_poll_scenario, params: {scenario: 'poll_expired_author', poll_type: poll_type, format: 'email'}
      assert_response :success
      assert_notification_headline("notifications.without_title.poll_expired_author")
      assert_element('.poll-mailer__create_outcome')
      assert_element('.poll-mailer-common-summary')
      assert_element('.poll-mailer-common-responses')
      assert_text('.poll-mailer__results-chart', "Results")
    end

    test "anonymous #{poll_type} poll_expired_author_email" do
      get :test_poll_scenario, params: {scenario: 'poll_expired_author', poll_type: poll_type, anonymous: true, format: 'email'}
      assert_response :success
      assert_notification_headline("notifications.without_title.poll_expired_author")
      assert_element('.poll-mailer__create_outcome')
      assert_element('.poll-mailer-common-summary')
      assert_element('.poll-mailer-common-responses')
      assert_text('.poll-mailer__results-chart', "Results")
      assert_text('.poll-mailer-common-responses', "Anonymous")
    end

    test "#{poll_type} compare view" do
      get :test_poll_scenario, params: {scenario: 'poll_created', poll_type: poll_type, format: 'compare'}
      assert_response :success
      assert_includes response.body, "Format Comparison"
      assert_includes response.body, "compare-grid"
    end
  end
end
