ExampleContent = Struct.new(:group) do
  include Routing

  def add_to_group!
    group.add_member!(helper_bot).tap do
      Events::NewDiscussion.publish!(introduction_thread)
      Events::NewMotion.publish!(example_motion)
    end.destroy # remove helper bot after s/he has made example content
  end

  def introduction_thread
    @introduction_thread ||= group.discussions.create(
      title:         I18n.t('introduction_thread.title', group_name: group.name),
      description:   I18n.t('introduction_thread.description'),
      author:        helper_bot,
      private:       !!group.discussion_private_default,
      uses_markdown: true
    )
  end

  def how_it_works_thread
    @how_it_works_thread ||= group.discussions.create(
      author:        helper_bot,
      title:         I18n.t('how_it_works_thread.title'),
      description:   I18n.t('how_it_works_thread.description', thread_url: discussion_url(introduction_thread)),
      private:       !!group.discussion_private_default,
      uses_markdown: true
    )
  end

  def example_motion
    @example_motion ||= how_it_works_thread.motions.create(
      author:       helper_bot,
      name:         I18n.t('first_proposal.name'),
      description:  I18n.t('first_proposal.description'),
      closing_at:  (Time.zone.now + 7.days).at_beginning_of_hour
    )
  end

  def helper_bot
    @helper_bot ||= User.helper_bot
  end

end
