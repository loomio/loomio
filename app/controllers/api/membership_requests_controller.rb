class API::MembershipRequestsController < API::RestfulController

  def pending
    load_and_authorize :group
    @membership_requests = @group.membership_requests.pending
    respond_with_collection
  end

  private

  def visible_records
    load_and_authorize :group
    Queries::VisibleMemberships.new(user: current_user, group: @group)
  end

end
