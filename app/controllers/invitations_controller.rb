class InvitationsController < ApplicationController
  include PrettyUrlHelper

  rescue_from(ActiveRecord::RecordNotFound)    { respond_with_error message: :"invitation.invitation_not_found", status: 404 }
  rescue_from(Invitation::InvitationCancelled) { respond_with_error message: :"invitation.invitation_cancelled" }
  rescue_from(Invitation::InvitationAlreadyUsed) do
    if current_user.email == invitation.recipient_email
      redirect_to group_path(invitation.group)
    else
      respond_with_error message: :"invitation.invitation_already_used"
    end
  end

  def show
    if current_user.is_logged_in?
      InvitationService.redeem(invitation, current_user)
      session.delete(:pending_invitation_id)
    else
      session[:pending_invitation_id] = params[:id]
    end

    if back_to_param.match(/^http[s]?:\/\/#{ENV['CANONICAL_HOST']}/)
      redirect_to back_to_param
    else
      redirect_to group_url(invitation.group)
    end
  end

  private

  def invitation
    @invitation ||= Invitation.find_by_token!(params[:id])
  end

  def invitation_callback
  end

  def back_to_param
    @back_to_param ||= URI.unescape params[:back_to].to_s
  end
end
