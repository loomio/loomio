class InvitationsController < ApplicationController
  include InvitationsHelper
  include PrettyUrlHelper

  before_filter :clear_invitation_token_from_session, only: :show

  rescue_from(ActiveRecord::RecordNotFound)    { respond_with_error :"invitation.invitation_not_found" }
  rescue_from(Invitation::InvitationCancelled) { respond_with_error :"invitation.invitation_cancelled" }
  rescue_from(Invitation::InvitationAlreadyUsed) do
    if current_user and invitation.accepted?
      redirect_to invitation.invitable
    else
      respond_with_error :"invitation.invitation_already_used"
    end
  end

  def show
    return require_login unless current_user_or_visitor.is_logged_in?
    InvitationService.redeem(invitation, current_user)
    redirect_to group_url(invitation.invitable)
  end

  private

  def require_login
    save_invitation_token_to_session
    redirect_to login_or_signup_path_for_email(invitation.recipient_email)
  end

  def invitation
    @invitation ||= Invitation.find_by_token!(params[:id])
  end
end
