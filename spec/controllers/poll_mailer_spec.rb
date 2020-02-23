require 'rails_helper'

def expect_text(selector, val)
  Nokogiri::HTML(ActionMailer::Base.deliveries.last.body.parts.last.decoded).css(selector).to_s
end

def expect_element(selector)
  Nokogiri::HTML(ActionMailer::Base.deliveries.last.body.parts.last.decoded).css(selector).to_s.length > 0
end

describe Dev::PollsController do
  it 'test_proposal_poll_created_email' do
    get :test_proposal_poll_created_email
    expect_text('.poll-mailer__subject', "invited you to vote on a proposal")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Please respond")
  end

  it 'test_poll_poll_created_email' do
    get :test_poll_poll_created_email
    expect_text('.poll-mailer__subject', "invited you to vote in a poll")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Please respond")
  end

  it 'test_count_poll_created_email' do
    get :test_count_poll_created_email
    expect_text('.poll-mailer__subject', "invited you to participate in a count")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Please respond")
  end

  it 'test_dot_vote_poll_created_email' do
    get :test_dot_vote_poll_created_email
    expect_text('.poll-mailer__subject', "invited you to participate in a dot vote")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Vote now")
  end

  it 'test_meeting_poll_created_email' do
    get :test_meeting_poll_created_email
    expect_text('.poll-mailer__subject', "invited you to participate in a time poll")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Vote now")
  end

  it 'test_ranked_choice_poll_created_email' do
    get :test_ranked_choice_poll_created_email
    expect_text('.poll-mailer__subject', "invited you to rank options in a poll")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Vote now")
  end

  it 'test_score_poll_created_email' do
    get :test_score_poll_created_email
    expect_text('.poll-mailer__subject', "invited you to vote in a score poll")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Vote now")
  end
end
