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

  it 'test_proposal_poll_edited_email' do
    get :test_proposal_poll_edited_email
    expect_text('.poll-mailer__subject', "edited the proposal")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "You voted")
    expect_text('.poll-mailer-proposal__chart', "Results")
    expect_text('.poll-mailer-common-responses', "Responses")
  end

  it 'test_poll_poll_edited_email' do
    get :test_poll_poll_edited_email
    expect_text('.poll-mailer__subject', "edited the poll")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "You voted")
    expect_text('.poll-mailer-common-bar-chart', "Results")
    expect_text('.poll-mailer-common-responses', "Responses")
  end

  it 'test_count_poll_edited_email' do
    get :test_count_poll_edited_email
    expect_text('.poll-mailer__subject', "edited the check")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "You voted")
    expect_text('.poll-mailer-common-bar-chart', "Results")
    expect_text('.poll-mailer-common-responses', "Responses")
  end

  it 'test_dot_vote_poll_edited_email' do
    get :test_dot_vote_poll_edited_email
    expect_text('.poll-mailer__subject', "edited the dot vote")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "You voted")
    expect_text('.poll-mailer-common-bar-chart', "Results")
    expect_text('.poll-mailer-dot-vote-responses', "Responses")
  end

  it 'test_meeting_poll_edited_email' do
    get :test_meeting_poll_edited_email
    expect_text('.poll-mailer__subject', "edited the time poll")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "You voted")
    expect_text('.poll-mailer__meeting-chart', "Results")
    expect_text('.poll-mailer-meeting-responses', "Responses")
  end

  it 'test_ranked_choice_poll_edited_email' do
    get :test_ranked_choice_poll_edited_email
    expect_text('.poll-mailer__subject', "edited the ranked choice")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "You voted")
    expect_text('.poll-mailer-ranked-choice__chart', "Results")
    expect_text('.poll-mailer-ranked-choice-responses', "Responses")
  end

  it 'test_score_poll_edited_email' do
    get :test_score_poll_edited_email
    expect_text('.poll-mailer__subject', "edited the poll")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "You voted")
    expect_text('.poll-mailer-common-bar-chart', "Results")
    expect_text('.poll-mailer-score-responses', "Responses")
  end

  it 'test_proposal_poll_outcome_created_email' do
    get :test_proposal_poll_outcome_created_email
    expect_text('.poll-mailer__subject', "shared a proposal outcome")
    expect_text('.poll-mailer-common-summary', "Outcome")
    expect_text('.poll-mailer-proposal__chart', "Results")
    expect_text('.poll-mailer-common-responses', "Responses")
  end

  it 'test_poll_poll_outcome_created_email' do
    get :test_poll_poll_outcome_created_email
    expect_text('.poll-mailer__subject', "shared a poll outcome")
    expect_text('.poll-mailer-common-summary', "Outcome")
    expect_text('.poll-mailer-common-bar-chart', "Results")
    expect_text('.poll-mailer-common-responses', "Responses")
  end

  it 'test_count_poll_outcome_created_email' do
    get :test_count_poll_outcome_created_email
    expect_text('.poll-mailer__subject', "shared an outcome")
    expect_text('.poll-mailer-common-summary', "Outcome")
    expect_text('.poll-mailer-common-bar-chart', "Results")
    expect_text('.poll-mailer-common-responses', "Responses")
  end

  it 'test_dot_vote_poll_outcome_created_email' do
    get :test_dot_vote_poll_outcome_created_email
    expect_text('.poll-mailer__subject', "shared a dot vote outcome")
    expect_text('.poll-mailer-common-summary', "Outcome")
    expect_text('.poll-mailer-common-bar-chart', "Results")
    expect_text('.poll-mailer-dot-vote-responses', "Responses")
  end

  it 'test_meeting_poll_outcome_created_email' do
    get :test_meeting_poll_outcome_created_email
    expect_text('.poll-mailer__subject', "shared a time poll outcome")
    expect_text('.poll-mailer-common-summary', "Outcome")
    expect_text('.poll-mailer__meeting-chart', "Results")
    expect_text('.poll-mailer-meeting-responses', "Responses")
  end

  it 'test_ranked_choice_poll_outcome_created_email' do
    get :test_ranked_choice_poll_outcome_created_email
    expect_text('.poll-mailer__subject', "shared a ranked choice outcome")
    expect_text('.poll-mailer-common-summary', "Outcome")
    expect_text('.poll-mailer-ranked-choice__chart', "Results")
    expect_text('.poll-mailer-ranked-choice-responses', "Responses")
  end

  it 'test_score_poll_outcome_created_email' do
    get :test_score_poll_outcome_created_email
    expect_text('.poll-mailer__subject', "shared a poll outcome")
    expect_text('.poll-mailer-common-summary', "Outcome")
    expect_text('.poll-mailer-common-bar-chart', "Results")
    expect_text('.poll-mailer-score-responses', "Responses")
  end

  it 'test_proposal_poll_stance_created_email' do
    get :test_proposal_poll_stance_created_email
    expect_text('.poll-mailer__subject', "voted on")
    expect_element('.poll-mailer__stance')
  end

  it 'test_poll_poll_stance_created_email' do
    get :test_poll_poll_stance_created_email
    expect_text('.poll-mailer__subject', "voted on")
    expect_element('.poll-mailer__stance')
  end

  it 'test_count_poll_stance_created_email' do
    get :test_count_poll_stance_created_email
    expect_text('.poll-mailer__subject', "participated in")
    expect_element('.poll-mailer__stance')
  end

  it 'test_dot_vote_poll_stance_created_email' do
    get :test_dot_vote_poll_stance_created_email
    expect_text('.poll-mailer__subject', "voted on")
    expect_element('.poll-mailer__stance')
  end

  it 'test_meeting_poll_stance_created_email' do
    get :test_meeting_poll_stance_created_email
    expect_text('.poll-mailer__subject', "participated in")
    expect_element('.poll-mailer__stance')
  end

  # it 'test_ranked_choice_poll_stance_created_email' do
  #   # GK: the setup task fails for this for some reason; something to do with stance choices
  #   get :test_ranked_choice_poll_stance_created_email
  #   expect_text('.poll-mailer__subject', "voted on")
  #   expect_element('.poll-mailer__stance')
  # end

  it 'test_score_poll_stance_created_email' do
    get :test_score_poll_stance_created_email
    expect_text('.poll-mailer__subject', "voted on")
    expect_element('.poll-mailer__stance')
  end

  it 'test_proposal_poll_closing_soon_email' do
    get :test_proposal_poll_closing_soon_email
    expect_text('.poll-mailer__subject', "is closing in 24 hours")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Please respond")
  end

  it 'test_poll_poll_closing_soon_email' do
    get :test_poll_poll_closing_soon_email
    expect_text('.poll-mailer__subject', "is closing in 24 hours")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Please respond")
  end

  it 'test_count_poll_closing_soon_email' do
    get :test_count_poll_closing_soon_email
    expect_text('.poll-mailer__subject', "is closing in 24 hours")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Please respond")
  end

  it 'test_dot_vote_poll_closing_soon_email' do
    get :test_dot_vote_poll_closing_soon_email
    expect_text('.poll-mailer__subject', "is closing in 24 hours")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Vote now")
  end

  it 'test_meeting_poll_closing_soon_email' do
    get :test_meeting_poll_closing_soon_email
    expect_text('.poll-mailer__subject', "is closing in 24 hours")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Vote now")
  end

  it 'test_ranked_choice_poll_closing_soon_email' do
    get :test_ranked_choice_poll_closing_soon_email
    expect_text('.poll-mailer__subject', "is closing in 24 hours")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Vote now")
  end

  it 'test_score_poll_closing_soon_email' do
    get :test_score_poll_closing_soon_email
    expect_text('.poll-mailer__subject', "is closing in 24 hours")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Vote now")
  end

  it 'test_proposal_poll_closing_soon_author_email' do
    get :test_proposal_poll_closing_soon_author_email
    expect_text('.poll-mailer__subject', "is closing in 24 hours")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Please respond")
  end

  it 'test_poll_poll_closing_soon_author_email' do
    get :test_poll_poll_closing_soon_author_email
    expect_text('.poll-mailer__subject', "is closing in 24 hours")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Please respond")
  end

  it 'test_count_poll_closing_soon_author_email' do
    get :test_count_poll_closing_soon_author_email
    expect_text('.poll-mailer__subject', "is closing in 24 hours")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Please respond")
  end

  it 'test_dot_vote_poll_closing_soon_author_email' do
    get :test_dot_vote_poll_closing_soon_author_email
    expect_text('.poll-mailer__subject', "is closing in 24 hours")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Vote now")
  end

  it 'test_meeting_poll_closing_soon_author_email' do
    get :test_meeting_poll_closing_soon_author_email
    expect_text('.poll-mailer__subject', "is closing in 24 hours")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Vote now")
  end

  it 'test_ranked_choice_poll_closing_soon_author_email' do
    get :test_ranked_choice_poll_closing_soon_author_email
    expect_text('.poll-mailer__subject', "is closing in 24 hours")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Vote now")
  end

  it 'test_score_poll_closing_soon_author_email' do
    get :test_score_poll_closing_soon_author_email
    expect_text('.poll-mailer__subject', "is closing in 24 hours")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Vote now")
  end

  it 'test_proposal_poll_user_mentioned_email' do
    get :test_proposal_poll_user_mentioned_email
    expect_text('.poll-mailer__subject', "mentioned you in")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Please respond")
  end

  it 'test_poll_poll_user_mentioned_email' do
    get :test_poll_poll_user_mentioned_email
    expect_text('.poll-mailer__subject', "mentioned you in")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Please respond")
  end

  it 'test_count_poll_user_mentioned_email' do
    get :test_count_poll_user_mentioned_email
    expect_text('.poll-mailer__subject', "mentioned you in")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Please respond")
  end

  it 'test_dot_vote_poll_user_mentioned_email' do
    get :test_dot_vote_poll_user_mentioned_email
    expect_text('.poll-mailer__subject', "mentioned you in")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Vote now")
  end

  it 'test_meeting_poll_user_mentioned_email' do
    get :test_meeting_poll_user_mentioned_email
    expect_text('.poll-mailer__subject', "mentioned you in")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Vote now")
  end

  # it 'test_ranked_choice_poll_user_mentioned_email' do
  #   get :test_ranked_choice_poll_user_mentioned_email
  #   expect_text('.poll-mailer__subject', "mentioned you in")
  #   expect_element('.poll-mailer-common-summary')
  #   expect_text('.poll-mailer__vote', "Vote now")
  # end

  it 'test_score_poll_user_mentioned_email' do
    get :test_score_poll_user_mentioned_email
    expect_text('.poll-mailer__subject', "mentioned you in")
    expect_element('.poll-mailer-common-summary')
    expect_text('.poll-mailer__vote', "Vote now")
  end

  it 'test_proposal_poll_expired_author_email' do
    get :test_proposal_poll_expired_author_email
    expect_text('.poll-mailer__subject', "has closed")
    expect_element('.poll-mailer__create_outcome')
    expect_element('.poll-mailer-common-summary')
    expect_element('.poll-mailer-common-responses')
    expect_text('.poll-mailer-proposal__chart', "Results")
  end

  it 'test_poll_poll_expired_author_email' do
    get :test_poll_poll_expired_author_email
    expect_text('.poll-mailer__subject', "has closed")
    expect_element('.poll-mailer__create_outcome')
    expect_element('.poll-mailer-common-summary')
    expect_element('.poll-mailer-common-responses')
    expect_text('.poll-mailer-common-bar-chart', "Results")
  end

  it 'test_count_poll_expired_author_email' do
    get :test_count_poll_expired_author_email
    expect_text('.poll-mailer__subject', "has closed")
    expect_element('.poll-mailer__create_outcome')
    expect_element('.poll-mailer-common-summary')
    expect_element('.poll-mailer-common-responses')
    expect_text('.poll-mailer-common-bar-chart', "Results")
  end

  it 'test_dot_vote_poll_expired_author_email' do
    get :test_dot_vote_poll_expired_author_email
    expect_text('.poll-mailer__subject', "has closed")
    expect_element('.poll-mailer__create_outcome')
    expect_element('.poll-mailer-common-summary')
    expect_element('.poll-mailer-dot-vote-responses')
    expect_text('.poll-mailer-common-bar-chart', "Results")
  end

  it 'test_meeting_poll_expired_author_email' do
    get :test_meeting_poll_expired_author_email
    expect_text('.poll-mailer__subject', "has closed")
    expect_element('.poll-mailer__create_outcome')
    expect_element('.poll-mailer-common-summary')
    expect_element('.poll-mailer-meeting-responses')
    expect_text('.poll-mailer__meeting-chart', "Results")
  end

  it 'test_ranked_choice_poll_expired_author_email' do
    get :test_ranked_choice_poll_expired_author_email
    expect_text('.poll-mailer__subject', "has closed")
    expect_element('.poll-mailer__create_outcome')
    expect_element('.poll-mailer-common-summary')
    expect_element('.poll-mailer-ranked-choice-responses')
    expect_text('.poll-mailer-ranked-choice__chart', "Results")
  end

  it 'test_score_poll_expired_author_email' do
    get :test_score_poll_expired_author_email
    expect_text('.poll-mailer__subject', "has closed")
    expect_element('.poll-mailer__create_outcome')
    expect_element('.poll-mailer-common-summary')
    expect_element('.poll-mailer-score-responses')
    expect_text('.poll-mailer-common-bar-chart', "Results")
  end

  it 'test_poll_poll_options_added_author_email' do
    get :test_poll_poll_options_added_author_email
    expect_text('.poll-mailer__subject', "added options to")
    expect_element('.poll-mailer-common-option-added')
    expect_element('.poll-mailer__vote')
  end

  it 'test_dot_vote_poll_options_added_author_email' do
    get :test_dot_vote_poll_options_added_author_email
    expect_text('.poll-mailer__subject', "added options to")
    expect_element('.poll-mailer-common-option-added')
    expect_element('.poll-mailer__vote')
  end

  it 'test_meeting_poll_options_added_author_email' do
    get :test_meeting_poll_options_added_author_email
    expect_text('.poll-mailer__subject', "added options to")
    expect_element('.poll-mailer-common-option-added')
    expect_element('.poll-mailer__vote')
  end

  it 'test_ranked_choice_poll_options_added_author_email' do
    get :test_ranked_choice_poll_options_added_author_email
    expect_text('.poll-mailer__subject', "added options to")
    expect_element('.poll-mailer-common-option-added')
    expect_element('.poll-mailer__vote')
  end

  it 'test_score_poll_options_added_author_email' do
    get :test_score_poll_options_added_author_email
    expect_text('.poll-mailer__subject', "added options to")
    expect_element('.poll-mailer-common-option-added')
    expect_element('.poll-mailer__vote')
  end


end
