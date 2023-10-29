class OnboardingCampaign < ApplicationCampaign
  step :new_subscription,
    subject: "New subscription"

  step :invitations,
    subject: "Invitations"

  step :using_threads,
    subject: "Using threads"

  step :using_polls,
    subject: "Using polls"

  step :make_a_decision,
    subject: "Make a decision"

  step :organize,
    subject: "Organize"
end
