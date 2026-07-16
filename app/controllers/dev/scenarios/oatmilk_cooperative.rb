module Dev::Scenarios::OatmilkCooperative
  def setup_manual_oatmilk_group
    group, coordinator = create_manual_oatmilk_cooperative

    sign_in coordinator
    redirect_to group_path(group)
  end

  def setup_manual_oatmilk_discussion
    _group, coordinator, discussion = create_manual_oatmilk_cooperative

    sign_in coordinator
    redirect_to discussion_path(discussion)
  end

  private

  def create_manual_oatmilk_cooperative
    coordinator = create_manual_oatmilk_member(
      name: 'Jamie Chen',
      email: 'jamie@oatmilk.example'
    )
    production_lead = create_manual_oatmilk_member(
      name: 'Samira Patel',
      email: 'samira@oatmilk.example'
    )
    sales_lead = create_manual_oatmilk_member(
      name: 'Alex Morgan',
      email: 'alex@oatmilk.example'
    )

    group = Group.new(
      name: 'Oatmilk Cooperative',
      handle: 'oatmilk-cooperative',
      description: 'We make oat milk for local cafes and shops. We use Loomio to discuss our work and make decisions together.',
      group_privacy: 'closed',
      discussion_privacy_options: 'public_or_private',
      creator: coordinator
    )
    GroupService.create(group: group, actor: coordinator)
    group.add_admin!(coordinator)
    group.add_member!(production_lead)
    group.add_member!(sales_lead)

    discussion = DiscussionService.create(
      params: {
        group_id: group.id,
        title: 'Returnable bottles for cafe customers',
        description: 'Several cafe customers have asked about reusable packaging. Use this thread to share practical questions before we decide whether to run a trial.',
        private: false
      },
      actor: production_lead
    )

    CommentService.create(
      comment: Comment.new(
        parent: discussion,
        body: 'I can ask three cafes to track how many bottles are returned each week.'
      ),
      actor: sales_lead
    )

    PollService.create(
      params: {
        topic_id: discussion.topic_id,
        title: 'Run a six-week returnable bottle trial',
        details: 'Supply returnable glass bottles to three cafe customers, then review the return rate, cleaning time, and transport costs.',
        poll_type: 'proposal',
        poll_option_names: %w[agree abstain disagree block],
        closing_at: 1.week.from_now
      },
      actor: coordinator
    )

    DiscussionService.create(
      params: {
        group_id: group.id,
        title: 'Weekly production schedule',
        description: 'Plan production shifts and delivery days for the coming month.',
        private: false
      },
      actor: coordinator
    )

    [group, coordinator, discussion]
  end

  def create_manual_oatmilk_member(name:, email:)
    User.create!(
      name: name,
      email: email,
      password: 'password',
      detected_locale: 'en',
      email_verified: true,
      experiences: {changePicture: true, hideOnboarding: true, theme: 'light'}
    )
  end
end
