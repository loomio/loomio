class UserMailerPreview < ActionMailer::Preview
  def missed_yesterday
    recipient = FactoryGirl.create(:user)
    actor = FactoryGirl.create(:user)

    group = FactoryGirl.create(:group)
    group.add_member!(recipient)
    group.add_admin!(actor)

    discussion = FactoryGirl.create(:discussion, group: group, author: actor)
    DiscussionService.create(discussion: discussion, actor: actor)

    comment = FactoryGirl.create :comment, discussion: discussion, body: "New comment", uses_markdown: true
    comment.attachments << FactoryGirl.create(:attachment)
    CommentService.create(comment: comment, actor: actor)

    motion = FactoryGirl.build(:motion, discussion: discussion, author: actor)
    MotionService.create(motion: motion, actor: actor)

    vote  = Vote.new(motion: motion, user: discussion.author, position: 'yes', statement: 'Oh yes in deeedee')
    VoteService.create(vote: vote, actor: actor)

    discussion = FactoryGirl.create(:discussion, group: group, author: actor)
    DiscussionService.create(discussion: discussion, actor: actor)

    motion = FactoryGirl.create(:motion,
                               author: actor,
                               discussion: discussion,
                               closed_at: 1.hour.ago,
                               outcome: "We all agreed to go ahead with the proposal",
                               outcome_author: discussion.author)
    MotionService.create(motion: motion, actor: actor)

    UserMailer.missed_yesterday(recipient)
  end

  def group_membership_approved
    user = FactoryGirl.create(:user)
    group = FactoryGirl.create(:group)
    UserMailer.group_membership_approved(user, group)
  end

  def added_to_group
    user = FactoryGirl.create(:user)
    inviter = FactoryGirl.create(:user)
    group = FactoryGirl.create(:group)
    group.add_member!(inviter)
    message = "Hello! It's been a long time coming but I thought you would be the best person to invite to the group now that we're developing a unifying agreement plan consenting process"
    UserMailer.added_to_group(user: user, inviter: inviter, group: group, message: message)
  end
end
