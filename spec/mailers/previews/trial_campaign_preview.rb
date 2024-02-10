# Preview all emails at http://localhost:3000/rails/mailers/
class TrialCampaignPreview < ActionMailer::Preview
  def welcome
    TrialCampaign.welcome(user)
  end

  def first_vote
    TrialCampaign.first_vote(user)
  end

  def making_a_decision
    TrialCampaign.making_a_decision(user)
  end

  def trial_ended
    TrialCampaign.trial_ended(user)
  end

  def win_back_attempt
    TrialCampaign.win_back_attempt(user)
  end

  private

  def user
    User.where(id: params[:user_id]).first || User.first || User.new(email: "user@example.com").freeze
  end
end
