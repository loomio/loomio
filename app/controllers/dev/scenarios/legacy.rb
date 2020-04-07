module Dev::Scenarios::Legacy
  def setup_discussion_mailer_new_comment_email
    @group = FormalGroup.create!(name: 'Dirty Dancing Shoes')
    @group.add_admin!(patrick).set_volume!(:loud)
    @group.add_member! jennifer

    @discussion = Discussion.new(title: 'What star sign are you?',
                                 group: @group,
                                 description: "Wow, what a __great__ day.",
                                 author: jennifer)
    DiscussionService.create(discussion: @discussion, actor: @discussion.author)
    @comment = Comment.new(author: jennifer, body: "hello _patrick_.", discussion: @discussion)
    CommentService.create(comment: @comment, actor: jennifer)
    last_email
  end

  def setup_group_invitation_ignored
    group  = FactoryBot.create :formal_group
    event = GroupService.announce(group: group, actor: group.creator, params: { emails: ['hello@example.com']})
    ActionMailer::Base.deliveries.clear
    AnnouncementService.resend_pending_memberships(since: 1.hour.ago, till: 1.hour.from_now)
    last_email
  end

  def setup_discussion_invitation_ignored
    model = FactoryBot.create :discussion
    event = GroupService.announce(group: model, actor: model.author, params: { emails: ['hello@example.com']})
    ActionMailer::Base.deliveries.clear
    AnnouncementService.resend_pending_memberships(since: 1.hour.ago, till: 1.hour.from_now)
    last_email
  end

  def setup_poll_invitation_ignored
    model = FactoryBot.create :poll
    event = GroupService.announce(group: model, actor: model.author, params: { emails: ['hello@example.com']})
    ActionMailer::Base.deliveries.clear
    AnnouncementService.resend_pending_memberships(since: 1.hour.ago, till: 1.hour.from_now)
    last_email
  end

  def setup_discussion_mailer_user_mentioned_email
    @group = FormalGroup.create!(name: 'Dirty Dancing Shoes')
    @group.add_admin!(patrick)
    @group.add_member! jennifer

    @discussion = Discussion.new(title: 'What star sign are you?',
                                 group: @group,
                                 description: "hey @patrickswayze wanna dance?",
                                 author: jennifer)
    DiscussionService.create(discussion: @discussion, actor: @discussion.author)
    last_email
  end

  def setup_discussion_mailer_comment_replied_to_email
    @group = FormalGroup.create!(name: 'Dirty Dancing Shoes')
    @group.add_admin!(patrick)
    @group.add_member! jennifer

    @discussion = Discussion.new(title: 'What star sign are you?',
                                 group: @group,
                                 description: "Wow, what a __great__ day.",
                                 author: jennifer)
    DiscussionService.create(discussion: @discussion, actor: @discussion.author)
    @comment = Comment.new(body: "hello _patrick.", discussion: @discussion)
    CommentService.create(comment: @comment, actor: jennifer)
    @reply_comment = Comment.new(body: "why, hello there jen", parent: @comment, discussion: @discussion)
    CommentService.create(comment: @reply_comment, actor: patrick)
    last_email
  end

  def setup_group_with_documents
    sign_in patrick
    create_group

    (params[:times]||1).to_i.times do |i|
      FactoryBot.create :document, model: create_group, created_at: 3.days.ago, author: patrick
      FactoryBot.create :document, model: create_group
      FactoryBot.create :document, model: create_group, title: "a really outragously long title you wouldn't really use exept for in some really extraneous circumstances"
    end

    redirect_to   group_url(create_group)
  end

  def setup_explore_groups
    sign_in patrick
    30.times do |i|
      explore_group = FormalGroup.new(name: Faker::Name.name, group_privacy: 'open', is_visible_to_public: true)
      GroupService.create(group: explore_group, actor: patrick)
      explore_group.update_attribute(:memberships_count, i)
    end
    FormalGroup.limit(15).update_all(name: 'Footloose')
    redirect_to group_url(FormalGroup.last)
  end

  def setup_group_with_pinned_discussion
    sign_in patrick
    create_discussion.update(pinned: true)
    redirect_to group_url(create_discussion.group)
  end

  def setup_accounts_merged_email
    UserMailer.accounts_merged(patrick.id).deliver_now
    last_email
  end

  def setup_invitation_to_user
    membership = FactoryBot.create(:membership,
      user: FactoryBot.create(:user, email: jennifer.email, email_verified: false),
      group: create_group
    )
    redirect_to membership_url(membership)
  end
end
