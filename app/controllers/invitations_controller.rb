class InvitationsController < ApplicationController
  include PrettyUrlHelper

  rescue_from(ActiveRecord::RecordNotFound)    { respond_with_error :"invitation.invitation_not_found", status: :not_found }
  rescue_from(Invitation::InvitationCancelled) { respond_with_error :"invitation.invitation_cancelled" }
  rescue_from(Invitation::InvitationAlreadyUsed) do
    if current_user.email == invitation.recipient_email
      redirect_to invitation.invitable
    else
      respond_with_error :"invitation.invitation_already_used"
    end
  end

  def show
    if current_user.is_logged_in?
      InvitationService.redeem(invitation, current_user)
      session[:invitation_token] = nil
      redirect_to group_url(invitation.invitable)
    else
      session[:invitation_token] = params[:id]
      redirect_to login_or_signup_path_for_email(invitation.recipient_email)
    end
  end

  private

  def invitation
    @invitation ||= Invitation.find_by_token!(params[:id])
  end
end
