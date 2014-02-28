class InvitationsController < ApplicationController
  include InvitationsHelper
  before_filter :load_invitable, only: [:new, :create]
  before_filter :ensure_invitations_available, only: [:new, :create]

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
      redirect_to @invitation.invitable
    else
      render 'application/display_error',
        locals: { message: t(:'invitation.invitation_already_used') }
    end
  end

  def new
    @invite_people_form = InvitePeopleForm.new
  end

  def create
    require_current_user_can_invite_people
    @invite_people_form = InvitePeopleForm.new(params[:invite_people_form])

    if @invitable.kind_of?(Group)
      MembershipService.add_users_to_group(users: @invite_people_form.members_to_add,
                                           group: @group,
                                           inviter: current_user,
                                           message: @invite_people_form.message_body)

      InvitationService.invite_to_group(recipient_emails: @invite_people_form.emails_to_invite,
                                        message: @invite_people_form.message_body,
                                        group: @invitable,
                                        inviter: current_user)

    elsif @invitable.kind_of?(Discussion)
      MembershipService.add_users_to_discussion(users: @invite_people_form.members_to_add,
                                                discussion: @discussion,
                                                inviter: current_user,
                                                message: @invite_people_form.message_body)

      InvitationService.invite_to_discussion(recipient_emails: @invite_people_form.emails_to_invite,
                                             message: @invite_people_form.message_body,
                                             discussion: @invitable,
                                             inviter: current_user)
    end

    set_flash_message
    redirect_to @invitable
  end

  def show
    clear_invitation_token_from_session
    @invitation = Invitation.find_by_token!(params[:id])

    if @invitation.cancelled?
      raise Invitation::InvitationCancelled
    end

    if @invitation.accepted?
      raise Invitation::InvitationAlreadyUsed
    end

    if current_user
      AcceptInvitation.and_grant_access!(@invitation, current_user)
      redirect_to @invitation.invitable
    else
      save_invitation_token_to_session
      redirect_to new_user_registration_path
    end
  end

  def destroy
    @invitation = Invitation.find_by_token!(params[:id])

    authorize! :cancel, @invitation
    @invitation.cancel!(canceller: current_user)

    redirect_to group_memberships_path(@invitation.group),
                notice: "Invitation to #{@invitation.recipient_email} cancelled"
  end

  private

  def ensure_invitations_available
    unless @group.invitations_remaining > 0
      render 'no_invitations_left'
    end
  end

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

  def join_or_setup_group_path
    group = @invitation.invitable
    if group.admins.include? current_user
      setup_group_path(group)
    else
      group_path(group)
    end
  end
end
