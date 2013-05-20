class InvitationsController < ApplicationController
  def show
    @invitation = Invitation.find_by_token(params[:id])

    if current_user
      AcceptInvitation.and_grant_access!(@invitation, current_user)
      session[:invitation_token] = nil
      if @invitation.group.admins.include? current_user
        redirect_to setup_group_path(@invitation.group.id)
      else
        redirect_to @invitation.group
      end
    else
      session[:invitation_token] = params[:id]
      @user = User.new
      if @invitation.intent == 'join_group'
        render template: 'invitations/join_group', layout: 'pages'
      else
        render template: 'invitations/start_group', layout: 'pages'
      end
    end
  end
end
