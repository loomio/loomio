class FirstDecisionCampaign < ApplicationCampaign
  step :welcome,
    subject: "Making your first decision on Loomio"
  step :discussion,
    subject: "Your first decision: discussing a topic"
  step :proposal,
    subject: "Your first decision: raising a proposal"
  step :outcome,
    subject: "Your first decision: sharing an outcome"
end
