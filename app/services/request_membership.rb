class RequestMembership
  def self.to_group(params: nil, group: nil, requestor: nil)
    membership_request = MembershipRequest.new(params)
    membership_request.group = group
    membership_request.requestor = requestor
    if membership_request.save
      Events::MembershipRequested.publish!(membership_request)
    end
    membership_request
  end
end
