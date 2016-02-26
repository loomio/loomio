class API::InvitationsController < API::RestfulController

  def create
    instantiate_collection { service.invite_to_group(recipient_emails: email_addresses,
                                                     group: load_and_authorize(:group, :invite_people),
                                                     inviter: current_user,
                                                     message: invitation_form_params[:message]) }
    respond_with_collection
  end

  def pending
    load_and_authorize(:group, :view_pending_invitations)
    instantiate_collection { @group.invitations.pending) }
    respond_with_collection
  end

  def shareable
    load_and_authorize(:group, :view_shareable_invitation)
    instantiate_collection { Array(service.shareable_invitation_for(@group)) }
    respond_with_collection
  end

  private

  def invitation_form_params
    params.require(:invitation_form)
  end

  def email_addresses
    invitation_form_params[:emails].scan(/[^\s,;<>]+?@[^\s,;<>]+\.[^\s,;<>]+/).take(100)
  end

end
