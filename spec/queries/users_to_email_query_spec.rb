require 'rails_helper'

describe UsersToEmailQuery do
  let(:user_with_thread_volume_email) { FactoryGirl.create :user }
  let(:user_with_new_discussion_notifications) { FactoryGirl.create :user, email_when_proposal_closing_soon: true }
  let(:user_with_motion_closing_soon_notifications) { FactoryGirl.create :user }
  let(:discussion) { FactoryGirl.create :discussion }
  let(:mentioned_user) {FactoryGirl.create :user, username: 'sam' }
  let(:parent_comment) { FactoryGirl.create :comment, discussion: discussion}
  let(:comment) { FactoryGirl.create :comment, parent: parent_comment, discussion: discussion, body: 'hey @sam' }
  let(:motion) { FactoryGirl.create :motion, discussion: discussion }
  let(:vote) { FactoryGirl.create :vote, motion: motion }

  before do
    parent_comment
    discussion.group.add_member!(mentioned_user).set_volume! :email
    discussion.group.add_member!(parent_comment.author).set_volume! :email
    discussion.group.add_member!(user_with_thread_volume_email).set_volume! :email
    discussion.group.add_member!(user_with_new_discussion_notifications)
    discussion.group.add_member!(user_with_motion_closing_soon_notifications)

    user_with_new_discussion_notifications.
      update_attribute :email_new_discussions_and_proposals, true
  end

  it 'new comment' do
    users = UsersToEmailQuery.new_comment(comment)
    users.should     include user_with_thread_volume_email
    users.should_not include comment.author
    users.should_not include mentioned_user
    users.should_not include comment.parent.author
  end

  it 'new_vote' do
    users = UsersToEmailQuery.new_vote(vote)
    users.should     include user_with_thread_volume_email
    users.should_not include vote.author
  end

  it 'new_discussion', focus: true do
    users = UsersToEmailQuery.new_discussion(discussion)
    users.should     include user_with_thread_volume_email
    users.should     include user_with_new_discussion_notifications

    users.should_not include discussion.author
  end

  it 'new_motion' do
    users = UsersToEmailQuery.new_motion(motion)
    users.should     include user_with_thread_volume_email
    users.should     include user_with_new_discussion_notifications

    users.should_not include motion.author
  end

  it 'motion_closing_soon' do
    users = UsersToEmailQuery.motion_closing_soon(motion)
    users.should     include user_with_thread_volume_email,
                             user_with_motion_closing_soon_notifications
  end

  it 'motion_outcome' do
    users = UsersToEmailQuery.motion_outcome(motion)
    users.should     include user_with_thread_volume_email
    users.should_not include motion.outcome_author
  end

  it 'motion_closed' do
    users = UsersToEmailQuery.motion_closed(motion)
    users.should     include user_with_thread_volume_email
  end
end
