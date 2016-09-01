require 'rails_helper'

describe Queries::UsersToEmailQuery do
  let(:all_emails_disabled) { {email_when_proposal_closing_soon: false} }
  let(:user_left_group) { FactoryGirl.create :user, all_emails_disabled }
  let(:user_thread_loud) { FactoryGirl.create :user, all_emails_disabled }
  let(:user_thread_normal) { FactoryGirl.create :user, all_emails_disabled }
  let(:user_thread_quiet) { FactoryGirl.create :user, all_emails_disabled }
  let(:user_thread_mute) { FactoryGirl.create :user, all_emails_disabled }
  let(:user_membership_loud) { FactoryGirl.create :user, all_emails_disabled }
  let(:user_membership_normal) { FactoryGirl.create :user, all_emails_disabled }
  let(:user_membership_quiet) { FactoryGirl.create :user, all_emails_disabled }
  let(:user_membership_mute) { FactoryGirl.create :user, all_emails_disabled }
  let(:user_motion_closing_soon) { FactoryGirl.create :user, all_emails_disabled.merge(email_when_proposal_closing_soon: true) }
  let(:user_mentioned) { FactoryGirl.create :user }
  let(:user_mentioned_text) { "Hello @#{user_mentioned.username}" }

  let(:discussion) { FactoryGirl.create :discussion, description: user_mentioned_text }
  let(:mentioned_user) {FactoryGirl.create :user, username: 'sam' }
  let(:parent_comment) { FactoryGirl.create :comment, discussion: discussion}
  let(:comment) { FactoryGirl.create :comment, parent: parent_comment, discussion: discussion, body: 'hey @sam' }
  let(:motion) { FactoryGirl.create :motion, discussion: discussion, description: user_mentioned_text }
  let(:vote) { FactoryGirl.create :vote, motion: motion }

  before do
    parent_comment
    discussion.group.add_member!(mentioned_user)
    discussion.group.add_member!(parent_comment.author)

    m = discussion.group.add_member!(user_left_group)
    DiscussionReader.for(discussion: discussion, user: user_left_group).set_volume! :loud
    m.destroy

    discussion.group.add_member!(user_thread_loud).set_volume! :mute
    discussion.group.add_member!(user_thread_normal).set_volume! :mute
    discussion.group.add_member!(user_thread_quiet).set_volume! :mute
    discussion.group.add_member!(user_thread_mute).set_volume! :mute
    discussion.group.add_member!(user_mentioned)

    DiscussionReader.for(discussion: discussion, user: user_thread_loud).set_volume! :loud
    DiscussionReader.for(discussion: discussion, user: user_thread_normal).set_volume! :normal
    DiscussionReader.for(discussion: discussion, user: user_thread_quiet).set_volume! :quiet
    DiscussionReader.for(discussion: discussion, user: user_thread_mute).set_volume! :mute

    # set membership volume - email for new discussions and proposals
    discussion.group.add_member!(user_membership_loud).set_volume! :loud
    discussion.group.add_member!(user_membership_normal).set_volume! :normal
    discussion.group.add_member!(user_membership_quiet).set_volume! :quiet
    discussion.group.add_member!(user_membership_mute).set_volume! :mute

    # set email motion closing soon
    discussion.group.add_member!(user_motion_closing_soon).set_volume! :mute
  end

  it 'new comment' do
    users = Queries::UsersToEmailQuery.new_comment(comment)
    users.should     include user_thread_loud
    users.should     include user_membership_loud

    users.should_not include user_left_group

    users.should_not include user_membership_normal
    users.should_not include user_thread_normal

    users.should_not include user_membership_quiet
    users.should_not include user_thread_quiet

    users.should_not include user_membership_mute
    users.should_not include user_thread_mute

    users.should_not include comment.author
    users.should_not include mentioned_user
    users.should_not include comment.parent.author
  end

  it 'new_vote' do
    users = Queries::UsersToEmailQuery.new_vote(vote)
    users.should     include user_thread_loud
    users.should     include user_membership_loud

    users.should_not include user_membership_normal
    users.should_not include user_thread_normal

    users.should_not include user_membership_quiet
    users.should_not include user_thread_quiet

    users.should_not include user_membership_mute
    users.should_not include user_thread_mute

    users.should_not include vote.author
  end

  it 'new_discussion' do
    users = Queries::UsersToEmailQuery.new_discussion(discussion)
    users.should     include user_thread_loud
    users.should     include user_membership_loud

    users.should     include user_membership_normal
    users.should     include user_thread_normal

    users.should_not include user_membership_quiet
    users.should_not include user_thread_quiet

    users.should_not include user_membership_mute
    users.should_not include user_thread_mute

    users.should_not include discussion.author
    users.should_not include user_mentioned
  end

  it 'new_motion' do
    users = Queries::UsersToEmailQuery.new_motion(motion)
    users.should     include user_thread_loud
    users.should     include user_membership_loud

    users.should     include user_membership_normal
    users.should     include user_thread_normal

    users.should_not include user_membership_quiet
    users.should_not include user_thread_quiet

    users.should_not include user_membership_mute
    users.should_not include user_thread_mute

    users.should_not include motion.author
    users.should_not include user_mentioned
  end

  it 'motion_closing_soon' do
    users = Queries::UsersToEmailQuery.motion_closing_soon(motion)
    users.should     include user_thread_loud
    users.should     include user_membership_loud

    users.should     include user_membership_normal
    users.should     include user_thread_normal

    users.should_not include user_membership_quiet
    users.should_not include user_thread_quiet

    users.should_not include user_membership_mute
    users.should_not include user_thread_mute

    users.should     include user_motion_closing_soon
  end

  it 'motion_outcome' do
    users = Queries::UsersToEmailQuery.motion_outcome_created(motion)
    users.should     include user_thread_loud
    users.should     include user_membership_loud

    users.should     include user_membership_normal
    users.should     include user_thread_normal

    users.should_not include user_membership_quiet
    users.should_not include user_thread_quiet

    users.should_not include user_membership_mute
    users.should_not include user_thread_mute

    users.should_not include user_motion_closing_soon
  end

  it 'motion_closed' do
    users = Queries::UsersToEmailQuery.motion_closed(motion)
    users.should     include user_thread_loud
    users.should     include user_membership_loud

    users.should     include user_membership_normal
    users.should     include user_thread_normal

    users.should_not include user_membership_quiet
    users.should_not include user_thread_quiet

    users.should_not include user_membership_mute
    users.should_not include user_thread_mute
  end
end
