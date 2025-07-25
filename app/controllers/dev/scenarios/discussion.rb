module Dev::Scenarios::Discussion
  def setup_discussion
    create_discussion
    sign_in patrick
    redirect_to discussion_path(create_discussion)
  end

  def setup_multiple_discussions
    sign_in patrick
    create_discussion
    create_public_discussion
    redirect_to discussion_path(create_discussion)
  end

  def setup_discussion_as_guest
    group      = FactoryBot.create :group, group_privacy: 'secret'
    discussion = FactoryBot.build :discussion, group: group, title: "Dirty Dancing Shoes"
    DiscussionService.create(discussion: discussion, actor: discussion.group.creator)
    discussion.add_guest!(jennifer, discussion.author)
    sign_in jennifer

    redirect_to discussion_path(discussion)
  end

  def setup_discussion_with_guest
    group      = FactoryBot.create :group, group_privacy: 'secret'
    discussion = FactoryBot.build :discussion, group: group, title: "Dirty Dancing Shoes"
    group.add_member!(patrick)
    DiscussionService.create(discussion: discussion, actor: discussion.group.creator)
    discussion.add_guest!(jennifer, discussion.author)
    sign_in patrick

    redirect_to discussion_path(discussion)
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

    redirect_to discussion_path(create_discussion)
  end

  def setup_thread_catch_up
    jennifer.update(email_catch_up_day: 7)
    CommentService.create(comment: FactoryBot.create(:comment, discussion: create_discussion, body: "first comment"), actor: patrick)
    event = CommentService.create(comment: FactoryBot.create(:comment, discussion: create_discussion, body: "removed comment"), actor: patrick)
    CommentService.discard(comment: event.eventable, actor: event.user)
    DiscussionService.update(discussion: create_discussion,
                             params: {recipient_message: 'this is an edit message'},
                             actor: patrick)
    poll = fake_poll
    PollService.create(poll: poll, actor: patrick)
    create_fake_stances(poll: poll)
    PollService.update(poll: poll, actor: patrick, params: {recipient_message: 'updated the poll here <br> newline'})
    DiscussionService.close(discussion: create_discussion, actor: patrick)
    UserMailer.catch_up(jennifer.id, 1.hour.ago).deliver_now
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
    redirect_to discussion_path(create_discussion)
  end

  def setup_discussion_for_jennifer
    sign_in jennifer
    redirect_to discussion_path(create_discussion)
  end

  def setup_open_and_closed_discussions
    create_discussion
    create_closed_discussion
    sign_in patrick
    patrick.update(experiences: { closingThread: true })
    redirect_to group_path(create_group)
  end

  def setup_pages_of_closed_discussions
    @group = saved(fake_group)
    @group.add_admin!(patrick)
    sign_in patrick
    60.times do
      saved(fake_discussion(group: @group, closed_at: 5.days.ago))
    end
    redirect_to group_path(@group)
  end

  def setup_comment_with_versions
    comment = Comment.new(discussion: create_discussion, body: "What star sign are you?")
    CommentService.create(comment: comment, actor: jennifer)
    comment.update(body: "What moon sign are you?")
    comment.update_versions_count
    sign_in patrick
    redirect_to discussion_path(create_discussion)
  end

  def setup_discussion_with_versions
    create_discussion
    create_discussion.update(title: "What moon sign are you?")
    create_discussion.update_versions_count
    sign_in patrick
    redirect_to discussion_path(create_discussion)
  end

  # discussion mailer emails

  def setup_discussion_mailer_discussion_created_email
    sign_in jennifer
    @group = FactoryBot.create(:group, name: "Girdy Dancing Shoes", creator: patrick)
    @group.add_admin! patrick
    @group.add_member! jennifer
    discussion = FactoryBot.build(:discussion, title: "Let's go to the moon!", group: @group)

    blob = ActiveStorage::Blob.create_and_upload!(
      io: File.open(Rails.root.join('spec', 'fixtures', 'images', 'strongbad.png')),
      filename: 'strongbad.png',
      content_type: 'image/jpeg'
    )
    discussion.files.attach(blob)

    DiscussionService.create(discussion: discussion, actor: patrick, params: {recipient_user_ids: [jennifer.id]})
    last_email
  end

  def setup_discussion_mailer_discussion_edited_email
    sign_in jennifer
    @group = FactoryBot.create(:group, name: "Girdy Dancing Shoes", creator: patrick)
    @group.add_admin! patrick
    @group.add_member! jennifer
    discussion = FactoryBot.build(:discussion, title: "Let's go to the moon!", group: @group)
    DiscussionService.create(discussion: discussion, actor: patrick)
    DiscussionService.update(discussion: discussion, actor: patrick, params: {recipient_user_ids: [jennifer.id], recipient_message: 'change message & ampersand <yo>! &nbsp;'})
    last_email
  end

  def setup_discussion_mailer_discussion_announced_email
    sign_in jennifer
    @group = FactoryBot.create(:group, name: "Girdy Dancing Shoes", creator: patrick)
    @group.add_admin! patrick
    @group.add_member! jennifer
    discussion = FactoryBot.build(:discussion, title: "Let's go to the moon!", group: @group)
    event = DiscussionService.create(discussion: discussion, actor: patrick)
    DiscussionService.invite(discussion: discussion, actor: patrick, params: {recipient_user_ids: [jennifer.id]})
    last_email
  end

  def setup_discussion_mailer_invitation_created_email
    group = FactoryBot.create(:group, name: "Dirty Dancing Shoes", creator: patrick)
    group.add_admin! patrick
    discussion = FactoryBot.build(:discussion, title: "Let's go to the moon!", group: group)
    event = DiscussionService.create(discussion: discussion, actor: patrick)
    comment = FactoryBot.build(:comment, discussion: discussion)
    CommentService.create(comment: comment, actor: patrick)
    DiscussionService.invite(discussion: discussion, actor: patrick, params: {recipient_emails: 'jen@example.com'})
    last_email
  end

  def setup_discussion_mailer_new_comment_email
    @group = Group.create!(name: 'Dirty Dancing Shoes')
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

  def setup_discussion_mailer_new_comment_thread_subscribed_email
      @group = Group.create!(name: 'Dirty Dancing Shoes')
      @group.add_admin!(patrick).set_volume!(:normal)
      @group.add_member! jennifer

      @discussion = Discussion.new(title: 'What star sign are you?',
                                   group: @group,
                                   description: "Wow, what a __great__ day.",
                                   author: jennifer)
      DiscussionService.create(discussion: @discussion, actor: @discussion.author)
      DiscussionReader.for(discussion: @discussion, user: @patrick).set_volume!(:loud)
      @comment = Comment.new(author: jennifer, body: "hello _patrick_.", discussion: @discussion)
      CommentService.create(comment: @comment, actor: jennifer)
      last_email
    end

  def setup_discussion_mailer_comment_replied_to_email
    @group = Group.create!(name: 'Dirty Dancing Shoes')
    @group.add_admin!(patrick)
    @group.add_member! jennifer


    @discussion = Discussion.new(title: 'What star sign are you?',
                                 group: @group,
                                 description: "Wow, what a __great__ day.",
                                 author: jennifer)
    DiscussionService.create(discussion: @discussion, actor: @discussion.author)
    @comment = Comment.new(body: "hello _patrick.", discussion: @discussion)
    CommentService.create(comment: @comment, actor: jennifer)
    @reply_comment = Comment.new(body: "why, hello there @#{jennifer.username}", parent: @comment, discussion: @discussion)
    CommentService.create(comment: @reply_comment, actor: patrick)
    last_email
  end

  def setup_discussion_mailer_user_mentioned_email
    @group = saved fake_group
    GroupService.create(group: @group, actor: patrick)

    @group.add_member! jennifer
    @discussion = fake_discussion(group: @group, description: "hey @#{patrick.username} wanna dance?")
    DiscussionService.create(discussion: @discussion, actor: jennifer)
    last_email
  end

  def setup_task_reminder_email
    @group = Group.create!(name: 'Dirty Dancing Shoes')
    @group.add_admin!(patrick)
    jennifer.update(time_zone: "Pacific/Auckland")
    @group.add_member! jennifer
    datestr = "2021-06-16"

    @discussion = Discussion.new(title: 'time to do your chores!',
                                 description_format: 'html',
                                 group: @group,
                                 description: "<li data-uid='123' data-type='taskItem' data-due-on='#{datestr}' data-remind='1'>this is a task for <span data-mention-id='#{jennifer.username}'>#{jennifer.name}</span></li>",
                                 author: jennifer)
    DiscussionService.create(discussion: @discussion, actor: @discussion.author)
    expected_remind_at = "{datestr} 06:00".in_time_zone("Pacific/Auckland") - 1.day
    TaskService.send_task_reminders(expected_remind_at)
    last_email
  end
end
