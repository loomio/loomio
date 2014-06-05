class MembershipRequestService
  attr_accessor :membership_request

  def initialize(membership_request)
    @membership_request = membership_request
  end

  def perform!
    if requestor.ability.can?(:create, membership_request)
      membership_request.save!
      Events::MembershipRequested.publish!(membership_request)
    else
      false
    end
  end

  private

  def requestor
    membership_request.requestor || LoggedOutUser.new
  end
end
