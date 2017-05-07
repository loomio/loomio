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
      session.delete(:pending_invitation_id)
      redirect_to group_url(invitation.invitable)
    else
      session[:pending_invitation_id] = params[:id]
      redirect_to group_url(invitation.invitable,
        sign_in_email: invitation.recipient_email,
        sign_in_name:  invitation.recipient_name
      )
    end
  end

  private

  def invitation
    @invitation ||= Invitation.find_by_token!(params[:id])
  end
end
