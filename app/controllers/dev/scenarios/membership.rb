module Dev::Scenarios::Membership
  def setup_group_as_member
    sign_in jennifer
    redirect_to group_url(create_group)
  end
end
