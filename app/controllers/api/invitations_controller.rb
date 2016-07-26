class Api::InvitationsController < Api::RestfulController
  def create
    fetch_and_authorize :group, :invite_people
    @invitations = InvitationService.invite_to_group(recipient_emails: email_addresses,
                                                     group: @group,
                                                     inviter: current_user,
                                                     message: invitation_form_params[:message])
    if @invitations.any?
      respond_with_collection
    else
      respond_with_errors
    end
  end

  def pending
    fetch_and_authorize :group, :view_pending_invitations
    @invitations = page_collection(@group.invitations.pending)
    respond_with_collection
  end

  def shareable
    fetch_and_authorize :group, :view_shareable_invitation
    @invitations = [service.shareable_invitation_for(@group)]
    respond_with_collection
  end

  def destroy
    service.cancel(invitation: fetch_resource, actor: current_user)
    respond_with_resource
  end

  private

  def invitation_form_params
    params.require(:invitation_form)
  end

  def email_addresses
    invitation_form_params[:emails].scan(/[^\s,;<>]+?@[^\s,;<>]+\.[^\s,;<>]+/).take(100)
  end

  def respond_with_errors
    render json: {errors: { emails: [  I18n.t('invitation_form.error.all_email_addresses_belong_to_members') ]}}, root: false, status: 422
  end

end
