class InvitationsController < ApplicationController
  include InvitationsHelper

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
    @invitation = Invitation.find_by_token(params[:id])

    if @invitation.nil?
      clear_invitation_token_from_session
      raise ActiveRecord::RecordNotFound
    end

    if @invitation.cancelled?
      clear_invitation_token_from_session
      raise Invitation::InvitationCancelled
    end

    if @invitation.accepted?
      clear_invitation_token_from_session
      raise Invitation::InvitationAlreadyUsed
    end

    if current_user
      AcceptInvitation.and_grant_access!(@invitation, current_user)
      clear_invitation_token_from_session
      redirect_to_group
    else
      save_invitation_token_to_session
      redirect_to new_user_registration_path
    end
  end

  private

  def redirect_to_group
    if @invitation.group.admins.include? current_user
      redirect_to setup_group_path(@invitation.group)
    else
      redirect_to @invitation.group
    end
  end
end
