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
      InvitationService.redeem(invitation, invitation_user, identity)
      sign_in invitation_user
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
    if !invitation_user && Identities::Base::PROVIDERS.include?(invitation.identity_type)
      send(:"#{invitation.identity_type}_oauth_url", team: invitation.slack_team_id, back_to: back_to)
    else
      back_to
    end
  end

  def back_to
    params.fetch(:back_to, group_url(invitation.group))
  end

  def invitation_user
    @invitation_user ||= identity&.user || current_user.presence || invitation.user_from_recipient!
  end

  def identity
    @identity ||= Identities::Base.find_by(
      identity_type: invitation.identity_type,
      uid: params[:uid]
    )
  end
end
