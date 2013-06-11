class SetupGroup
  attr_accessor :group_request

  def initialize(group_request)
    self.group_request = group_request
  end

  def approve_group_request(args)
    @group = Group.new
    @group.group_request = group_request

    %w[name cannot_contribute max_size].each do |attr|
      @group.send("#{attr}=", group_request.send(attr))
    end

    group_request.approve!(args)
    @group.save!
    @group
  end

  def send_invitation_to_start_group(args)
    invitation = CreateInvitation.to_start_group(group: group_request.group,
                                                inviter: args[:inviter],
                                                recipient_email: group_request.admin_email)

    InvitePeopleMailer.to_start_group(invitation, args[:inviter].email, args[:message_body]).deliver
    invitation
  end

  def self.create_example_discussion(group)
    helper_bot = find_or_create_helper_bot
    example_discussion = Discussion.new
    example_discussion.title = I18n.t('example_discussion.title')
    example_discussion.description = I18n.t('example_discussion.description')
    example_discussion.group = group
    example_discussion.author = helper_bot
    example_discussion.save!

    example_motion = Motion.new
    example_motion.name = I18n.t('example_motion.name')
    example_motion.description = I18n.t('example_motion.description')
    example_motion.author = helper_bot
    example_motion.discussion = example_discussion
    example_motion.close_at_date = 3.days.from_now.to_date
    example_motion.close_at_time = Time.now.strftime("%H:00")
    example_motion.close_at_time_zone = helper_bot.time_zone
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
