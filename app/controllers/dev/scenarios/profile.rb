module Dev::Scenarios::Profile
  def setup_restricted_profile
    sign_in patrick
    create_group = Group.create!(name: 'Secret Dirty Dancing Shoes',
                                group_privacy: 'secret')
    create_group.add_member!(jennifer)
    redirect_to "/u/#{jennifer.username}"
  end

  def setup_profile_with_group_visible_to_members
    sign_in patrick
    create_group = Group.create!(name: 'Secret Dirty Dancing Shoes',
                                group_privacy: 'secret')
    create_group.add_admin!(patrick)
    create_group.add_member!(jennifer)
    redirect_to "/u/#{jennifer.username}"
  end

  def setup_deactivated_user
    patrick.update(deactivated_at: 1.day.ago)
    redirect_to "/dashboard"
  end

  def setup_user_reactivation_email
    patrick.update(deactivated_at: 1.day.ago)
    UserService.reactivate(patrick.id)
    last_email
  end

  def setup_merge_verification_email
    source_user = patrick
    target_user = jennifer
    MergeUsersService.send_merge_verification_email(actor: source_user, target_email: target_user.email)
    sign_in target_user
    last_email
  end
end
