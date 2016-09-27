class Api::MembershipRequestsController < Api::RestfulController

  before_action :authorize, only: [:pending, :previous]

  def pending
    @membership_requests = page_collection(@group.membership_requests.pending)
    respond_with_collection
  end

  def my_pending
    fetch_and_authorize :group
    @membership_requests = @group.membership_requests.pending.where(requestor_id: current_user.id)
    respond_with_collection
  end

  def previous
    @membership_requests = page_collection(@group.membership_requests.responded_to)
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

  private

  def authorize
    fetch_and_authorize :group
    current_user.ability.authorize! :manage_membership_requests, @group
  end
end
