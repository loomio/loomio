class TrialCampaign < ApplicationCampaign
  step :welcome,
    subject: "Welcome"

  step :first_vote,
    subject: "First vote"

  step :making_a_decision,
    subject: "Making a decision"

  step :trial_ended,
    subject: "Trial ended"

  step :win_back_attempt,
    subject: "Win back attempt"
end
