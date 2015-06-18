class NetworkMembershipRequestsController < BaseController
  def new
    @request = NetworkMembershipRequest.new
  end

  def create
    @request = NetworkMembershipRequest.new permitted_params.network_membership_request
    NetworkMembershipRequestService.create network_membership_request: @request, actor: current_user
    flash[:notice] = I18n.t(:'networks.request_created')
    redirect_to network_path(@request.network)
  end

  def index
    @network = Network.friendly.find params[:network_id]
    @requests = @network.membership_requests
    current_user.ability.authorize! :manage_membership_requests, @network
  end

  def approve
    process_membership_request approve: true
  end

  def decline
    process_membership_request approve: false
  end

  private

  def process_membership_request(approve:)
    @network = Network.friendly.find params[:network_id]
    if approve
      NetworkMembershipRequestService.approve process_params
      flash[:notice] = I18n.t(:"networks.request_approved")
    else
      NetworkMembershipRequestService.decline process_params
      flash[:notice] = I18n.t(:"networks.request_approved")
    end
    redirect_to @network
  end

  def process_params
    { network_membership_request: @network.membership_requests.find(params[:id]), actor: current_user }
  end
end
