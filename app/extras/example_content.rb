class ExampleContent
  include Routing

  def self.add_to_group(group)
    example_content = self.new
    bot = example_content.helper_bot
    bot_membership = group.add_member! bot
    introduction_thread = example_content.introduction_thread(group)
    how_it_works_thread = example_content.how_it_works_thread(group)
    example_content.first_comment(how_it_works_thread, introduction_thread)
    first_proposal = example_content.first_proposal(how_it_works_thread)
    bot_membership.destroy
  end

  def helper_bot
    email = ENV['HELPER_BOT_EMAIL'] || 'contact@loomio.org'
    bot = User.find_by(email: email) ||
          User.create!(email: email,
                       name: 'Loomio Helper Bot',
                       password: SecureRandom.hex(20),
                       uses_markdown: true,
                       avatar_kind: 'gravatar')
  end

  def introduction_thread_content(group)
    {
      title: I18n.t('introduction_thread.title', group_name: group.name),
      description: I18n.t('introduction_thread.description'),
      group: group,
      author: helper_bot,
      private: !!group.discussion_private_default,
      uses_markdown: true
    }
  end

  def how_it_works_thread_content(group)
    {
      title: I18n.t('how_it_works_thread.title'),
      description: I18n.t('how_it_works_thread.description'),
      group: group,
      author: helper_bot,
      private: !!group.discussion_private_default,
      uses_markdown: true
    }
  end

  def first_proposal_content(thread)
    {
      name: I18n.t('first_proposal.name'),
      description: I18n.t('first_proposal.description'),
      discussion: thread,
      closing_at: (Time.zone.now + 7.days).at_beginning_of_hour
    }
  end

  def introduction_thread(group)
    thread = Discussion.new(introduction_thread_content(group))
    DiscussionService.create(discussion: thread, actor: helper_bot)
    thread
  end

  def how_it_works_thread(group)
    thread = Discussion.new(how_it_works_thread_content(group))
    DiscussionService.create(discussion: thread, actor: helper_bot)
    thread
  end

  def first_comment(how_it_works_thread, introduction_thread)
    comment = Comment.new(body: I18n.t('first_comment.body',
                                        hostname: ENV['CANONICAL_HOST'],
                                        thread_url: discussion_url(introduction_thread),
                                        group_name: how_it_works_thread.group.name),
                          discussion: how_it_works_thread)
    CommentService.create(comment: comment, actor: helper_bot)
    comment
  end

  def first_proposal(thread)
    proposal = Motion.new(first_proposal_content(thread))
    MotionService.create(motion: proposal, actor: helper_bot)
    proposal
  end

  def first_vote(proposal)
    vote = Vote.new(first_vote_content(proposal))
    VoteService.create(vote: vote, actor: helper_bot)
    vote
  end
end
