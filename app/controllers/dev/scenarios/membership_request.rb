module Dev::Scenarios::MembershipRequest
  def setup_membership_requests
    sign_in patrick
    create_group
    3.times do
      request = MembershipRequest.new(group: create_group, introduction: "I'd like to make decisions with y'all")
      MembershipRequestService.create(membership_request: request, actor: saved(fake_user))
    end
    redirect_to group_url(create_group)
  end
end
