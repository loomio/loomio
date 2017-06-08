class API::InvitationsController < API::RestfulController
  def create
    @invitations = service.invite_to_group(recipient_emails: email_addresses,
                                           group: load_and_authorize(:group, :invite_people),
                                           inviter: current_user)
    if @invitations.any?
      respond_with_collection
    else
      respond_with_errors
    end
  end

  def pending
    self.collection = page_collection(load_and_authorize(:group, :view_pending_invitations).invitations.pending)
    respond_with_collection
  end

  def shareable
    self.collection = Array(load_and_authorize(:group, :view_shareable_invitation).shareable_invitation)
    respond_with_collection
  end

  def destroy
    service.cancel(invitation: load_resource, actor: current_user)
    respond_with_resource
  end

  private

  def email_addresses
    params.require(:invitation_form)[:emails].scan(ReceivedEmail::EMAIL_REGEX)
  end

  def respond_with_errors
    render json: {errors: { emails: [  I18n.t('invitation_form.error.all_email_addresses_belong_to_members') ]}}, root: false, status: 422
  end

end
