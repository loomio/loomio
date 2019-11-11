ExampleContent = Struct.new(:group) do
  include Routing

  def add_to_group!
    group.add_admin!(helper_bot).tap do
      DiscussionService.create(discussion: how_it_works_thread, actor: helper_bot)
      PollService.create(poll: example_proposal, actor: helper_bot)
    end.destroy # remove helper bot after s/he has made example content
  end

  def how_it_works_thread
    @how_it_works_thread ||= group.discussions.build(
      author:        helper_bot,
      title:         I18n.t('how_it_works_thread.title'),
      description:   I18n.t('how_it_works_thread.description'),
      private:       !!group.discussion_private_default
    )
  end

  def example_proposal
    @example_proposal ||= how_it_works_thread.polls.build(
      poll_type:         :proposal,
      poll_option_names: %w[agree abstain disagree block],
      author:            helper_bot,
      title:             I18n.t('first_proposal.name'),
      details:           I18n.t('first_proposal.description'),
      closing_at:        (Time.zone.now + 7.days).at_beginning_of_hour
    )
  end

  def helper_bot
    @helper_bot ||= User.helper_bot
  end
end
