class InvitationsController < ApplicationController
  def show
    if current_user
      @invitation = AcceptInvitation.from_user_with_token(current_user, params[:id])
      redirect_to @invitation.group
    else
      session[:invitation_token] = params[:id]
      render template: 'invitations/please_sign_in'
    end
  end


end
