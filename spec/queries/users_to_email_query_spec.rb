require 'rails_helper'

describe UsersToEmailQuery do
  let(:all_emails_disabled) { {email_when_proposal_closing_soon: false} }
  let(:user_with_thread_volume_email) { FactoryGirl.create :user, all_emails_disabled }
  let(:user_with_membership_volume_normal) { FactoryGirl.create :user, all_emails_disabled }
  let(:user_with_membership_volume_mute) { FactoryGirl.create :user, all_emails_disabled }
  let(:user_with_membership_volume_email) { FactoryGirl.create :user, all_emails_disabled }
  let(:user_with_motion_closing_soon_notifications) { FactoryGirl.create :user, all_emails_disabled }

  let(:discussion) { FactoryGirl.create :discussion }
  let(:mentioned_user) {FactoryGirl.create :user, username: 'sam' }
  let(:parent_comment) { FactoryGirl.create :comment, discussion: discussion}
  let(:comment) { FactoryGirl.create :comment, parent: parent_comment, discussion: discussion, body: 'hey @sam' }
  let(:motion) { FactoryGirl.create :motion, discussion: discussion }
  let(:vote) { FactoryGirl.create :vote, motion: motion }

  before do
    parent_comment
    discussion.group.add_member!(mentioned_user)
    discussion.group.add_member!(parent_comment.author)

    # set thread volume email for all activity in thread
    discussion.group.add_member!(user_with_thread_volume_email)
    DiscussionReader.for(discussion: discussion, user: user_with_thread_volume_email).set_volume! :email

    # set membership volume - email for new discussions and proposals
    discussion.group.add_member!(user_with_membership_volume_email).set_volume! :email
    discussion.group.add_member!(user_with_membership_volume_normal).set_volume! :normal
    discussion.group.add_member!(user_with_membership_volume_mute).set_volume! :mute

    # set email motion closing soon
    user_with_motion_closing_soon_notifications.update_attribute(:email_when_proposal_closing_soon, true)
    discussion.group.add_member!(user_with_motion_closing_soon_notifications)
  end

  it 'new comment' do
    users = UsersToEmailQuery.new_comment(comment)
    users.should     include user_with_thread_volume_email
    users.should_not include user_with_membership_volume_email
    users.should_not include user_with_membership_volume_normal
    users.should_not include user_with_membership_volume_mute
    users.should_not include user_with_motion_closing_soon_notifications

    users.should_not include comment.author
    users.should_not include mentioned_user
    users.should_not include comment.parent.author
  end

  it 'new_vote' do
    users = UsersToEmailQuery.new_vote(vote)
    users.should     include user_with_thread_volume_email
    users.should_not include user_with_membership_volume_email
    users.should_not include user_with_membership_volume_normal
    users.should_not include user_with_membership_volume_mute
    users.should_not include user_with_motion_closing_soon_notifications

    users.should_not include vote.author
  end

  it 'new_discussion', focus: true do
    users = UsersToEmailQuery.new_discussion(discussion)
    users.should     include user_with_membership_volume_email
    users.should_not include user_with_membership_volume_normal
    users.should_not include user_with_membership_volume_mute
    users.should_not include user_with_motion_closing_soon_notifications

    users.should_not include discussion.author
  end

  it 'new_motion' do
    users = UsersToEmailQuery.new_motion(motion)
    users.should     include user_with_membership_volume_email
    users.should_not include user_with_membership_volume_normal
    users.should_not include user_with_membership_volume_mute
    users.should_not include user_with_motion_closing_soon_notifications
    users.should_not include motion.author
  end

  it 'motion_closing_soon' do
    users = UsersToEmailQuery.motion_closing_soon(motion)

    users.should     include user_with_thread_volume_email
    users.should     include user_with_motion_closing_soon_notifications

    users.should_not include user_with_membership_volume_email
    users.should_not include user_with_membership_volume_normal
    users.should_not include user_with_membership_volume_mute
  end

  it 'motion_outcome' do
    users = UsersToEmailQuery.motion_outcome(motion)
    users.should     include user_with_thread_volume_email

    users.should_not include user_with_membership_volume_email
    users.should_not include user_with_membership_volume_normal
    users.should_not include user_with_membership_volume_mute
    users.should_not include motion.outcome_author
  end

  it 'motion_closed' do
    users = UsersToEmailQuery.motion_closed(motion)
    users.should     include user_with_thread_volume_email

    users.should_not include user_with_membership_volume_email
    users.should_not include user_with_membership_volume_normal
    users.should_not include user_with_membership_volume_mute
  end
end
