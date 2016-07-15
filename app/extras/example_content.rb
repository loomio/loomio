ExampleContent = Struct.new(:group) do
  include Routing

  def add_to_group!(admin_invite: nil)
    group.add_member!(helper_bot).tap do
      Events::NewComment.publish!(example_comment)
      Events::NewMotion.publish!(example_motion)
      Events::NewVote.publish!(example_vote)
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
      description:   I18n.t('how_it_works_thread.description'),
      private:       !!group.discussion_private_default,
      uses_markdown: true
    )
  end

  def example_comment
    @example_comment ||= introduction_thread.comments.create(
      author:        helper_bot,
      body:          I18n.t('first_comment.body',
                             hostname: ENV['CANONICAL_HOST'],
                             thread_url: discussion_url(introduction_thread),
                             group_name: group.name)
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

  def example_vote
    @example_vote ||= example_motion.votes.create(
      author:       helper_bot,
      statement:    I18n.t('first_vote.statement'),
      position:     :yes
    )
  end

  def helper_bot
    @helper_bot ||= User.helper_bot
  end

end
