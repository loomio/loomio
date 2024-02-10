# Preview all emails at http://localhost:3000/rails/mailers/
class OnboardingCampaignPreview < ActionMailer::Preview
  def new_subscription
    OnboardingCampaign.new_subscription(user)
  end

  def invitations
    OnboardingCampaign.invitations(user)
  end

  def using_threads
    OnboardingCampaign.using_threads(user)
  end

  def using_polls
    OnboardingCampaign.using_polls(user)
  end

  def make_a_decision
    OnboardingCampaign.make_a_decision(user)
  end

  def organize
    OnboardingCampaign.organize(user)
  end

  private

  def user
    User.where(id: params[:user_id]).first || User.first || User.new(email: "user@example.com").freeze
  end
end
