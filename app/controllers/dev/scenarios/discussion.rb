module Dev::Scenarios::Discussion
  def setup_discussion
    create_discussion
    sign_in patrick
    redirect_to discussion_url(create_discussion)
  end

  def setup_discussion_mailer_new_discussion_email
    sign_in jennifer
    @group = FactoryBot.create(:formal_group, name: "Girdy Dancing Shoes", creator: patrick)
    @group.add_admin! patrick
    discussion = FactoryBot.build(:discussion, title: "Let's go to the moon!", group: @group)
    event = DiscussionService.create(discussion: discussion, actor: patrick)
    AnnouncementService.create(model: discussion, actor: patrick, params: {recipients: {user_ids: [jennifer.id]}, kind: "new_discussion"})
    last_email
  end

  def setup_discussion_mailer_invitation_created_email
    group = FactoryBot.create(:formal_group, name: "Dirty Dancing Shoes", creator: patrick)
    group.add_admin! patrick
    discussion = FactoryBot.build(:discussion, title: "Let's go to the moon!", group: group)
    event = DiscussionService.create(discussion: discussion, actor: patrick)
    comment = FactoryBot.build(:comment, discussion: discussion)
    CommentService.create(comment: comment, actor: patrick)
    AnnouncementService.create(model: discussion, actor: patrick, params: {recipients: {emails: 'jen@example.com'}, kind: "new_discussion"})
    last_email
  end

  def setup_multiple_discussions
    sign_in patrick
    create_discussion
    create_public_discussion
    redirect_to discussion_url(create_discussion)
  end

  def setup_discussion_as_guest
    group      = FactoryBot.create :formal_group, group_privacy: 'secret'
    discussion = FactoryBot.build :discussion, group: group, title: "Dirty Dancing Shoes"
    DiscussionService.create(discussion: discussion, actor: discussion.group.creator)
    discussion.create_guest_group
    discussion.reload.guest_group.add_member! jennifer
    sign_in jennifer

    redirect_to discussion_url(discussion)
  end

  def setup_forkable_discussion
    create_discussion
    create_another_discussion
    sign_in patrick
    CommentService.create(comment: FactoryBot.create(:comment, discussion: create_discussion, body: "This is totally on topic!"), actor: jennifer)
    event = CommentService.create(comment: FactoryBot.create(:comment, discussion: create_discussion, body: "This is totally **off** topic!"), actor: jennifer)
    CommentService.create(comment: FactoryBot.create(:comment, discussion: create_discussion, body: "This is a reply to the off-topic thing!", parent: event.eventable), actor: emilio)
    CommentService.create(comment: FactoryBot.create(:comment, discussion: create_discussion, body: "This is also off-topic"), actor: emilio)
    CommentService.create(comment: FactoryBot.create(:comment, discussion: create_discussion, body: "This is totally back on topic!"), actor: patrick)

    redirect_to discussion_url(create_discussion)
  end

  def setup_thread_catch_up
    jennifer.update(email_catch_up: true)
    CommentService.create(comment: FactoryBot.create(:comment, discussion: create_discussion), actor: patrick)
    DiscussionService.close(discussion: create_discussion, actor: patrick)
    UserMailer.catch_up(jennifer, 1.hour.ago).deliver_now
    last_email
  end

  def setup_unread_discussion
    read = Comment.new(discussion: create_discussion, body: "Here is some read content")
    unread = Comment.new(discussion: create_discussion, body: "Here is some unread content")
    another_unread = Comment.new(discussion: create_discussion, body: "Here is some more unread content")
    sign_in patrick

    CommentService.create(comment: read, actor: patrick)
    CommentService.create(comment: unread, actor: jennifer)
    CommentService.create(comment: another_unread, actor: jennifer)
    redirect_to discussion_url(create_discussion)
  end

  def setup_discussion_for_jennifer
    sign_in jennifer
    redirect_to discussion_url(create_discussion)
  end

  def setup_open_and_closed_discussions
    create_discussion
    create_closed_discussion
    sign_in patrick
    patrick.update(experiences: { closingThread: true })
    redirect_to group_url(create_group)
  end

  def setup_comment_with_versions
    comment = Comment.new(discussion: create_discussion, body: "What star sign are you?")
    CommentService.create(comment: comment, actor: jennifer)
    comment.update(body: "What moon sign are you?")
    comment.update_versions_count
    sign_in patrick
    redirect_to discussion_url(create_discussion)
  end

  def setup_discussion_with_versions
    create_discussion
    create_discussion.update(title: "What moon sign are you?")
    create_discussion.update_versions_count
    sign_in patrick
    redirect_to discussion_url(create_discussion)
  end
end
