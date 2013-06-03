class InvitationsController < ApplicationController

  rescue_from ActiveRecord::RecordNotFound do
    render 'application/display_error', 
      locals: { message: t(:'invitation.invitation_not_found') }
  end

  rescue_from Invitation::InvitationCancelled do
    render 'application/display_error', 
      locals: { message: t(:'invitation.invitation_cancelled') }
  end

  rescue_from Invitation::InvitationAlreadyUsed do
    if current_user and @invitation.accepted_by == current_user
      redirect_to @invitation.group
    else
      render 'application/display_error', 
        locals: { message: t(:'invitation.invitation_already_used') }
    end
  end


  def show
    load_invitation

    if @invitation.cancelled?
      raise Invitation::InvitationCancelled
    end

    if @invitation.accepted?
      raise Invitation::InvitationAlreadyUsed
    end

    if current_user
      AcceptInvitation.and_grant_access!(@invitation, current_user)
      clear_token_from_session
      redirect_to_group
    else
      save_token_to_session
      render_signup_form
    end
  end

  private
  def clear_token_from_session
    session[:invitation_token] = nil
  end

  def save_token_to_session
    session[:invitation_token] = params[:id]
  end

  def load_invitation
    @invitation = Invitation.find_by_token(params[:id])

    if @invitation.nil?
      raise ActiveRecord::RecordNotFound
    end
  end

  def redirect_to_group
    if @invitation.group.admins.include? current_user
      redirect_to setup_group_path(@invitation.group.id)
    else
      redirect_to @invitation.group
    end
  end

  def render_signup_form
    @user = User.new
    if @invitation.intent == 'join_group'
      render template: 'invitations/join_group', layout: 'pages'
    else
      @user_name = @invitation.group_request_admin_name
      render template: 'invitations/start_group', layout: 'pages'
    end
  end
end
