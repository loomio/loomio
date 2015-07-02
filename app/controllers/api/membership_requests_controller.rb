class API::MembershipRequestsController < API::RestfulController

  def pending
    load_and_authorize :group
    @membership_requests = @group.membership_requests.pending
    respond_with_collection
  end

  def responded_to
    load_and_authorize :group
    @membership_requests = @group.membership_requests.responded_to
    respond_with_collection
  end

  def approve
    load_and_authorize :group
    authorize! :manage_membership_requests, @group
    @membership_request = @group.membership_requests.where(id: params[:id]).first
    @membership_request.approve!(current_user)
    respond_with_resource
  end
end
