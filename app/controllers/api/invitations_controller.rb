class API::InvitationsController < API::RestfulController

  def create
    load_and_authorize :group, :invite_people

    MembershipService.add_users_to_group invitation_form.new_members
    InvitationService.invite_to_group    invitation_form.new_emails

    respond_with_collection
  end

  private

  def invitation_form
    @invitation_form ||= InvitationForm.new(group: @group, user: current_user, message: params[:invite_message], invitations: params[:invitations])
  end

end
