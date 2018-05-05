module Dev::Scenarios::JoinGroup
  def setup_public_group_to_join_upon_request
    sign_in jennifer
    create_another_group.update(group_privacy: 'open')
    create_another_group.update(membership_granted_upon: 'request')
    create_public_discussion
    redirect_to group_url(create_another_group)
  end

  def setup_closed_group_to_join
    sign_in jennifer
    create_another_group
    create_public_discussion
    private_create_discussion
    create_subgroup
    redirect_to group_url(create_another_group)
  end
end
