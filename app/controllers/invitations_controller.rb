class InvitationsController < ApplicationController
  include PrettyUrlHelper

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
      redirect_to polymorphic_url(invitation)
    end
  end

  private

  def invitation
    @invitation ||= Invitation.find_by_token!(params[:id])
  end

  def back_to_param
    @back_to_param ||= URI.unescape params[:back_to].to_s
  end
end
