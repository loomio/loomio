require 'rails_helper'

require_relative './mailer_helpers'

poll_types = %w[proposal poll dot_vote score count meeting ranked_choice]

describe Dev::PollsController do
  render_views
  poll_types.each do |poll_type|
    it "#{poll_type} created email" do
      get :test_poll_scenario, params: {scenario: 'poll_created', poll_type: poll_type, email: true}
      expect_text('.poll-mailer__subject', "invited you to")
      expect_subject("poll_mailer.header.poll_announced")
      expect_element('.poll-mailer-common-summary')
      expect_text('.poll-mailer__vote', "Please respond")
    end

    it "anonymous #{poll_type} created email" do
      get :test_poll_scenario, params: {scenario: 'poll_created', poll_type: poll_type, anonymous: true, email: true}
      expect_subject("poll_mailer.header.poll_announced")
      expect_element('.poll-mailer-common-summary')
      expect_text('.poll-mailer__vote', I18n.t("poll_common_action_panel.anonymous"))
      expect_text('.poll-mailer__vote', "Please respond")
    end

    it "#{poll_type} outcome_created email" do
      get :test_poll_scenario, params: {scenario: 'poll_outcome_created', poll_type: poll_type, email: true}
      expect_subject("poll_mailer.header.outcome_created")
      expect_text('.poll-mailer-common-summary', "Outcome")
      expect_text('.poll-mailer__results-chart', "Results")
      expect_text('.poll-mailer-common-responses', "Responses")
    end

    it "anonymous #{poll_type} outcome_created email" do
      get :test_poll_scenario, params: {scenario: 'poll_outcome_created', poll_type: poll_type, anonymous: true, email: true}
      expect_subject("poll_mailer.header.outcome_created")
      expect_text('.poll-mailer-common-summary', "Outcome")
      expect_text('.poll-mailer__results-chart', "Results")
      expect_text('.poll-mailer-common-responses', I18n.t("poll_common_action_panel.anonymous"))
      expect_text('.poll-mailer-common-responses', "Responses")
      expect_text('.poll-mailer-common-responses', "Anonymous")
    end

    it "#{poll_type} stance_created email" do
      get :test_poll_scenario, params: {scenario: 'poll_stance_created', poll_type: poll_type, email: true}
      expect_subject("poll_mailer.header.stance_created")
      expect_element('.poll-mailer__stance')
    end

    it "anonymous #{poll_type} stance_created email" do
      get :test_poll_scenario, params: {scenario: 'poll_stance_created', poll_type: poll_type, anonymous: true, email: true}
      expect_subject("poll_mailer.header.stance_created")
      expect_text(".poll-mailer__subject", "Anonymous")
      expect_element('.poll-mailer__stance')
    end

    it "results_hidden #{poll_type} stance_created email" do
      get :test_poll_scenario, params: {scenario: 'poll_stance_created', poll_type: poll_type, hide_results_until_closed: true, email: true}
      expect_subject("poll_mailer.header.stance_created")
      # TODO expect to see user, but not their position or reason
      expect_element('.poll-mailer__stance')
    end

    it "#{poll_type} poll_closing_soon email" do
      get :test_poll_scenario, params: {scenario: 'poll_closing_soon', poll_type: poll_type, email: true}
      expect_subject("poll_mailer.header.poll_closing_soon")
      expect_element('.poll-mailer-common-summary')
      expect_text('.poll-mailer__vote', "Please respond")
    end

    it "anonymous #{poll_type} poll_closing_soon email" do
      get :test_poll_scenario, params: {scenario: 'poll_closing_soon', poll_type: poll_type, anonymous: true, email: true}
      expect_subject("poll_mailer.header.poll_closing_soon")
      expect_element('.poll-mailer-common-summary')
      #TODO expect anonymous but see results
      expect_text('.poll-mailer__vote', "Please respond")
    end

    it "hide_results #{poll_type} poll_closing_soon email" do
      get :test_poll_scenario, params: {scenario: 'poll_closing_soon', poll_type: poll_type, hide_results_until_closed: true, email: true}
      expect_subject("poll_mailer.header.poll_closing_soon")
      expect_element('.poll-mailer-common-summary')
      #TODO expect no results panel, just a summary of how many people have voted
      expect_text('.poll-mailer__vote', "Please respond")
    end

    it "#{poll_type} poll_closing_soon_with_vote email" do
      next unless AppConfig.poll_templates.dig(poll_type, 'voters_review_responses')
      get :test_poll_scenario, params: {scenario: 'poll_closing_soon_with_vote', poll_type: poll_type, email: true}
      expect_subject("poll_mailer.header.poll_closing_soon")
      expect_element('.poll-mailer-common-summary')
      expect_text('.poll-mailer__vote', "You voted:")
    end

    it "anonymous #{poll_type} poll_closing_soon_with_vote email" do
      next unless AppConfig.poll_templates.dig(poll_type, 'voters_review_responses')
      get :test_poll_scenario, params: {scenario: 'poll_closing_soon_with_vote', poll_type: poll_type, anonymous: true, email: true}
      expect_subject("poll_mailer.header.poll_closing_soon")
      expect_element('.poll-mailer-common-summary')
      expect_text('.poll-mailer__vote', "You voted:")
      expect_text('.poll-mailer-common-responses', "Responses")
      expect_text('.poll-mailer-common-responses', "Anonymous")
      expect_no_element('.poll-mailer-common-undecided')
    end

    it "hide_results #{poll_type} poll_closing_soon_with_vote email" do
      next unless AppConfig.poll_templates.dig(poll_type, 'voters_review_responses')
      get :test_poll_scenario, params: {scenario: 'poll_closing_soon_with_vote', poll_type: poll_type, hide_results_until_closed: true, email: true}
      expect_subject("poll_mailer.header.poll_closing_soon")
      expect_text('.poll-mailer__vote', "You voted:")
      expect_text('.poll-mailer-common-responses', I18n.t(:'poll_common_action_panel.results_hidden_until_closed', poll_type: I18n.t(:"poll_types.#{poll_type}")))
      expect_text('.poll-mailer-common-undecided', "Undecided")
    end

    it "#{poll_type} poll_closing_soon_author email" do
      get :test_poll_scenario, params: {scenario: 'poll_closing_soon_author', poll_type: poll_type, email: true}
      expect_subject("poll_mailer.header.poll_closing_soon_author")
      expect_element('.poll-mailer-common-summary')
      expect_text('.poll-mailer__vote', "Please respond")
    end

    it "#{poll_type} poll_user_mentioned_email" do
      get :test_poll_scenario, params: {scenario: 'poll_user_mentioned', poll_type: poll_type, email: true}
      expect_subject("poll_mailer.header.user_mentioned")
      expect_element('.poll-mailer-common-summary')
      expect_text('.poll-mailer__vote', "Please respond")
    end

    it "anonymous #{poll_type} poll_user_mentioned_email" do
      get :test_poll_scenario, params: {scenario: 'poll_user_mentioned', anonymous: true, poll_type: poll_type, email: true}
      expect_text('.error', "no emails sent")
    end

    it "hidden #{poll_type} poll_user_mentioned_email" do
      get :test_poll_scenario, params: {scenario: 'poll_user_mentioned', hide_results_until_closed: true, poll_type: poll_type, email: true}
      expect_text('.error', "no emails sent")
    end

    it "#{poll_type} poll_expired_author_email" do
      get :test_poll_scenario, params: {scenario: 'poll_expired_author', poll_type: poll_type, email: true}
      expect_subject("poll_mailer.header.poll_expired_author")
      expect_element('.poll-mailer__create_outcome')
      expect_element('.poll-mailer-common-summary')
      expect_element('.poll-mailer-common-responses')
      expect_text('.poll-mailer__results-chart', "Results")
    end

    it "anonymous #{poll_type} poll_expired_author_email" do
      get :test_poll_scenario, params: {scenario: 'poll_expired_author', poll_type: poll_type, anonymous: true, email: true}
      expect_subject("poll_mailer.header.poll_expired_author")
      expect_element('.poll-mailer__create_outcome')
      expect_element('.poll-mailer-common-summary')
      expect_element('.poll-mailer-common-responses')
      expect_text('.poll-mailer__results-chart', "Results")
      expect_text('.poll-mailer-common-responses', "Anonymous")
    end

    it "#{poll_type} poll_options_added_author_email" do
      next if poll_type != "poll"
      get :test_poll_scenario, params: {scenario: 'poll_options_added_author', poll_type: poll_type, email: true}
      expect_text('.poll-mailer__subject', "added options to")
      expect_subject("poll_mailer.header.poll_option_added_author")
      expect_element('.poll-mailer-common-option-added')
      expect_element('.poll-mailer__vote')
    end

    it "anonymous #{poll_type} poll_options_added_author_email" do
      next if poll_type != "poll"
      get :test_poll_scenario, params: {scenario: 'poll_options_added_author', anonymous: true, poll_type: poll_type, email: true}
      expect_text('.poll-mailer__subject', "added options to")
      expect_subject("poll_mailer.header.poll_option_added_author")
      expect_element('.poll-mailer-common-option-added')
      expect_element('.poll-mailer__vote')
    end
  end
end
