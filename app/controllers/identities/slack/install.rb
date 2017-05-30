module Identities::Slack::Install
  # NB:
  # pending_identity comes from PendingActionsHelper,
  # boot_angular_ui comes from ApplicationController
  # oauth comes from Identities::BaseController
  def install
    if current_user.slack_identity || pending_identity
      boot_angular_ui
    else
      params[:back_to] = slack_install_url
      oauth
    end
  end
end
