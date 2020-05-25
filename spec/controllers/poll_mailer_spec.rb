require 'rails_helper'

def expect_text(selector, val)
  expect Nokogiri::HTML(ActionMailer::Base.deliveries.last.body.parts.last.decoded).css(selector).to_s == val
end

def expect_no_text(selector, val)
  expect Nokogiri::HTML(ActionMailer::Base.deliveries.last.body.parts.last.decoded).css(selector).to_s.length == 0
end

def expect_element(selector)
  expect Nokogiri::HTML(ActionMailer::Base.deliveries.last.body.parts.last.decoded).css(selector).to_s.length > 0
end

poll_types = %w[proposal poll dot_vote score count meeting ranked_choice]

describe Dev::PollsController do
  poll_types.each do |poll_type|
    it "#{poll_type} created email" do
      get :test_poll_scenario, params: {scenario: 'poll_created', poll_type: poll_type, email: true}
      expect_text('.poll-mailer__subject', "invited you to")
      expect_text('.poll-mailer__subject', I18n.t("#{poll_type}.header.poll_announced"))
      expect_element('.poll-mailer-common-summary')
      expect_text('.poll-mailer__vote', "Please respond")
    end

    it "anonymous #{poll_type} created email" do
      get :test_poll_scenario, params: {scenario: 'poll_created', poll_type: poll_type, anonymous: true, email: true}
      expect_text('.poll-mailer__subject', I18n.t("#{poll_type}.header.poll_announced"))
      expect_element('.poll-mailer-common-summary')
      expect_text('.poll-mailer__vote', I18n.t("poll_common_action_panel.anonymous"))
      expect_text('.poll-mailer__vote', "Please respond")
    end

    it "#{poll_type} poll_edited email" do
      get :test_poll_scenario, params: {scenario: 'poll_edited', poll_type: poll_type, email: true}
      expect_text('.poll-mailer__subject', I18n.t("#{poll_type}.header.poll_edited"))
      expect_element('.poll-mailer-common-summary')
      expect_text('.poll-mailer__vote', "You voted")
      expect_text('.poll-mailer-proposal__chart', "Results")
      expect_text('.poll-mailer-common-responses', "Responses")
    end

    it "anonymous #{poll_type} poll_edited email" do
      get :test_poll_scenario, params: {scenario: 'poll_edited', poll_type: poll_type, email: true}
      expect_text('.poll-mailer__subject', I18n.t("#{poll_type}.header.poll_edited"))
      expect_element('.poll-mailer-common-summary')
      expect_text('.poll-mailer__vote', "You voted")
      expect_text('.poll-mailer-proposal__chart', "Results")
      expect_no_text('.poll-mailer-common-responses', "Responses")
    end

    it "test #{poll_type} outcome_created email" do
      get :test_poll_scenario, params: {scenario: 'poll_outcome_created', poll_type: poll_type, email: true}
      expect_text('.poll-mailer__subject', I18n.t("#{poll_type}.header.outcome_created"))
      expect_text('.poll-mailer-common-summary', "Outcome")
      expect_text('.poll-mailer-proposal__chart', "Results")
      expect_text('.poll-mailer-common-responses', "Responses")
    end

    it "test #{poll_type} stance_created email" do
      get :test_poll_scenario, params: {scenario: 'poll_stance_created', poll_type: poll_type, email: true}
      expect_text('.poll-mailer__subject', I18n.t("#{poll_type}.subject.stance_created"))
      expect_element('.poll-mailer__stance')
    end

    it "test #{poll_type} poll_closing_soon email" do
      get :test_poll_scenario, params: {scenario: 'poll_closing_soon', poll_type: poll_type, email: true}
      expect_text('.poll-mailer__subject', I18n.t("#{poll_type}.header.poll_closing_soon"))
      expect_element('.poll-mailer-common-summary')
      expect_text('.poll-mailer__vote', "Please respond")
    end

    it "test #{poll_type} poll_closing_soon_author email" do
      get :test_poll_scenario, params: {scenario: 'poll_closing_soon', poll_type: poll_type, email: true}
      expect_text('.poll-mailer__subject', I18n.t("#{poll_type}.header.poll_closing_soon_author"))
      expect_element('.poll-mailer-common-summary')
      expect_text('.poll-mailer__vote', "Please respond")
    end

    it "test #{poll_type} poll_user_mentioned_email" do
      get :test_poll_scenario, params: {scenario: 'poll_user_mentioned', poll_type: poll_type, email: true}
      expect_text('.poll-mailer__subject', I18n.t("#{poll_type}.header.user_mentioned"))
      expect_element('.poll-mailer-common-summary')
      expect_text('.poll-mailer__vote', "Please respond")
    end

    it "test #{poll_type} poll_expired_author_email" do
      get :test_poll_scenario, params: {scenario: 'poll_expired_author', poll_type: poll_type, email: true}
      expect_text('.poll-mailer__subject', I18n.t("#{poll_type}.header.poll_expired_author"))
      expect_element('.poll-mailer__create_outcome')
      expect_element('.poll-mailer-common-summary')
      expect_element('.poll-mailer-common-responses')
      expect_text('.poll-mailer-proposal__chart', "Results")
    end

    it "test #{poll_type} poll_options_added_author_email" do
      get :test_poll_scenario, params: {scenario: 'poll_options_added_author', poll_type: poll_type, email: true}
      expect_text('.poll-mailer__subject', "added options to")
      expect_text('.poll-mailer__subject', I18n.t("#{poll_type}.header.poll_option_added_author"))
      expect_element('.poll-mailer-common-option-added')
      expect_element('.poll-mailer__vote')
    end
  end
end
