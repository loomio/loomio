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

  def setup_thread_missed_yesterday
    jennifer.update(email_missed_yesterday: true)
    CommentService.create(comment: FactoryBot.create(:comment, discussion: create_discussion), actor: patrick)
    DiscussionService.close(discussion: create_discussion, actor: patrick)
    UserMailer.missed_yesterday(jennifer, 1.hour.ago).deliver_now
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
end
