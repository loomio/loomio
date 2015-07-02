class API::MembershipRequestsController < API::RestfulController

  def pending
    load_and_authorize :group
    @membership_requests = @group.membership_requests.pending
    respond_with_collection
  end

  def previous
    load_and_authorize :group
    @membership_requests = @group.membership_requests.responded_to
    respond_with_collection
  end

  def approve
    @membership_request = MembershipRequest.find(params[:id])
    MembershipRequestService.approve(membership_request: @membership_request, actor: current_user)
    respond_with_resource
  end

  def ignore
    @membership_request = MembershipRequest.find(params[:id])
    MembershipRequestService.ignore(membership_request: @membership_request, actor: current_user)
    respond_with_resource
  end
end
