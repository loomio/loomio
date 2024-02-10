# Preview all emails at http://localhost:3000/rails/mailers/
class FirstDecisionCampaignPreview < ActionMailer::Preview
  def welcome
    FirstDecisionCampaign.welcome(user)
  end

  def decision
    FirstDecisionCampaign.decision(user)
  end

  def proposal
    FirstDecisionCampaign.proposal(user)
  end

  def outcome
    FirstDecisionCampaign.outcome(user)
  end

  private

  def user
    User.where(id: params[:user_id]).first || User.first || User.new(email: "user@example.com").freeze
  end
end
