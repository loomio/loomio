class SetupGroup
  def self.from_group_request(group_request)
    group = Group.new
    group.name = group_request.name
    group.payment_plan = group_request.payment_plan
    group.is_commercial = group_request.is_commercial
    group.group_request = group_request
    group.is_visible_to_public = false
    group.discussion_privacy_options = 'private_only'
    group.save!

    # do not create example discussion if the group is public discussions only
    SetupGroup.create_example_discussion(group) if group.discussion_privacy_options != 'public_only'
    send_invitation_to_start_group(group)
    group
  end

  def self.send_invitation_to_start_group(group)
    inviter = SetupGroup.find_or_create_helper_bot
    invitation = InvitationService.create_invite_to_start_group(group: group,
                                                                inviter: inviter,
                                                                recipient_email: group.group_request.admin_email,
                                                                recipient_name: group.group_request.admin_name)
    InvitePeopleMailer.delay.to_start_group(invitation, inviter.email)
    invitation
  end

  def self.create_example_discussion(group)
    helper_bot = find_or_create_helper_bot
    example_discussion = Discussion.new
    example_discussion.title = I18n.t('example_discussion.title')
    example_discussion.description = I18n.t('example_discussion.description')
    example_discussion.group = group
    example_discussion.author = helper_bot
    # dont fail when creating example discussion in public only group. Which shouldnt happen anyway now.
    example_discussion.private = !!group.discussion_private_default
    example_discussion.save!

    example_motion = Motion.new
    example_motion.name = I18n.t('example_motion.name')
    example_motion.description = I18n.t('example_motion.description')
    example_motion.author = helper_bot
    example_motion.discussion = example_discussion
    example_motion.save!
  end

  def self.find_or_create_helper_bot
    helper_bot = User.find_by_email('contact@loomio.org')
    unless helper_bot
      helper_bot = User.new
      helper_bot.name = 'Loomio Helper Bot'
      helper_bot.email = 'contact@loomio.org'
      helper_bot.password = SecureRandom.hex(20)
      helper_bot.save!
    end
    helper_bot
  end
end
