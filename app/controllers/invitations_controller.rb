class InvitationsController < ApplicationController
  include InvitationsHelper
  before_filter :load_invitable, only: [:new, :create]
  before_filter :authenticate_user!, only: :create

  rescue_from ActiveRecord::RecordNotFound do
    render 'application/display_error', locals: { message: t(:'invitation.invitation_not_found') }
  end

  rescue_from Invitation::InvitationCancelled do
    render 'application/display_error', locals: { message: t(:'invitation.invitation_cancelled') }
  end

  rescue_from Invitation::InvitationAlreadyUsed do
    if current_user and @invitation.accepted?
      redirect_to @invitation.invitable
    else
      render 'application/display_error', locals: { message: t(:'invitation.invitation_already_used') }
    end
  end

  def show
    clear_invitation_token_from_session
    @invitation = Invitation.find_by_token!(params[:id])

    if current_user
      InvitationService.redeem(@invitation, current_user)
      redirect_to @invitation.invitable
    else
      save_invitation_token_to_session
      redirect_to login_or_signup_path_for_email(@invitation.recipient_email)
    end
  end

  private

  def load_invitable
    if params[:group_id].present?
      @group = Group.find_by_key!(params[:group_id])
      @invitable = @group
    elsif params[:discussion_id].present?
      @discussion = Discussion.find_by_key!(params[:discussion_id])
      @group = @discussion.group
      @invitable = @discussion
    end
  end

  def set_flash_message
    unless @invite_people_form.emails_to_invite.empty?
      invitations_sent = t(:'notice.invitations.sent', count: @invite_people_form.emails_to_invite.size)
    end

    unless @invite_people_form.members_to_add.empty?
      members_added = t(:'notice.invitations.auto_added', count: @invite_people_form.members_to_add.size)
    end

    # expected output: 6 people invitations sent, 10 people added to group
    message = [invitations_sent, members_added].compact.join(", ")
    flash[:notice] = message
  end

  def require_current_user_can_invite_people
    unless can? :invite_people, @group
      flash[:error] = "You are not able to invite people to this group"
      redirect_to @invitable
    end
  end
end
