module Dev::Scenarios::Membership
  def setup_group_as_member
    create_group.update_admin_memberships_count
    sign_in jennifer
    redirect_to group_url(create_group)
  end

  def setup_membership_with_title
    sign_in patrick
    create_group.memberships.find_by(user: patrick).update(title: "Suzerain!")
    redirect_to group_url(create_group)
  end
end
