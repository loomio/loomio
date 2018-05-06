module Dev::Scenarios::Profile
  def setup_restricted_profile
    sign_in patrick
    create_group = FormalGroup.create!(name: 'Secret Dirty Dancing Shoes',
                                group_privacy: 'secret')
    create_group.add_member!(jennifer)
    redirect_to "/u/#{jennifer.username}"
  end

  def setup_profile_with_group_visible_to_members
    sign_in patrick
    create_group = FormalGroup.create!(name: 'Secret Dirty Dancing Shoes',
                                group_privacy: 'secret')
    create_group.add_admin!(patrick)
    create_group.add_member!(jennifer)
    redirect_to "/u/#{jennifer.username}"
  end
end
