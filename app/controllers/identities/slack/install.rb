module Identities::Slack::Install
  # NB:
  # pending_identity comes from PendingActionsHelper,
  # index comes from ApplicationController
  # oauth comes from Identities::BaseController
  def install
    if current_user.identities.find_by(identity_type: :slack) || pending_identity
      index
    else
      params[:back_to] = slack_install_url
      oauth
    end
  end
end
