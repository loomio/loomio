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
    if invitation_user
      sign_in invitation_user
      InvitationService.redeem(invitation, invitation_user)
      session.delete(:pending_invitation_id)
    else
      session[:pending_invitation_id] = params[:id]
    end
    redirect_to invitation_callback
  end

  private

  def invitation
    @invitation ||= Invitation.find_by_token!(params[:id])
  end

  def invitation_callback
    if !invitation_user && Identities::Base::PROVIDERS.include?(params[:auth_as].to_s)
      send(:"#{params[:auth_as]}_oauth_url", team: params[:team], back_to: group_callback)
    else
      params[:back_to] || group_callback
    end
  end

  def group_callback
    group_url(invitation.invitable)
  end

  def invitation_user
    @invitation_user ||= current_user.presence || invitation.user_from_recipient!
  end
end
