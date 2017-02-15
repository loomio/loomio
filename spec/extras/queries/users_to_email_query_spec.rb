# require 'rails_helper'
#
# describe Queries::UsersToEmailQuery do
#   let(:all_emails_disabled) { {email_when_proposal_closing_soon: false} }
#   let(:user_left_group) { FactoryGirl.create :user, all_emails_disabled }
#   let(:user_thread_loud) { FactoryGirl.create :user, all_emails_disabled }
#   let(:user_thread_normal) { FactoryGirl.create :user, all_emails_disabled }
#   let(:user_thread_quiet) { FactoryGirl.create :user, all_emails_disabled }
#   let(:user_thread_mute) { FactoryGirl.create :user, all_emails_disabled }
#   let(:user_membership_loud) { FactoryGirl.create :user, all_emails_disabled }
#   let(:user_membership_normal) { FactoryGirl.create :user, all_emails_disabled }
#   let(:user_membership_quiet) { FactoryGirl.create :user, all_emails_disabled }
#   let(:user_membership_mute) { FactoryGirl.create :user, all_emails_disabled }
#   let(:user_motion_closing_soon) { FactoryGirl.create :user, all_emails_disabled.merge(email_when_proposal_closing_soon: true) }
#   let(:user_mentioned) { FactoryGirl.create :user }
#   let(:user_mentioned_text) { "Hello @#{user_mentioned.username}" }
#   let(:user_poll_voted) { FactoryGirl.create :user }
#   let(:user_outcome_author) { FactoryGirl.create :user }
#
#   let(:discussion) { FactoryGirl.create :discussion, description: user_mentioned_text }
#   let(:mentioned_user) {FactoryGirl.create :user, username: 'sam' }
#   let(:parent_comment) { FactoryGirl.create :comment, discussion: discussion}
#   let(:comment) { FactoryGirl.create :comment, parent: parent_comment, discussion: discussion, body: 'hey @sam' }
#   let(:motion) { FactoryGirl.create :motion, discussion: discussion, description: user_mentioned_text }
#   let(:vote) { FactoryGirl.create :vote, motion: motion }
#   let(:poll) { FactoryGirl.create :poll, discussion: discussion }
#   let(:outcome) { FactoryGirl.create :outcome, author: user_outcome_author, poll: poll }
#   let(:stance) { FactoryGirl.create :stance, participant: user_poll_voted, poll: poll }
#
#   before do
#     stance
#     parent_comment
#     discussion.group.add_member!(mentioned_user)
#     discussion.group.add_member!(parent_comment.author)
#
#     m = discussion.group.add_member!(user_left_group)
#     DiscussionReader.for(discussion: discussion, user: user_left_group).set_volume! :loud
#     m.destroy
#
#     discussion.group.add_member!(user_thread_loud).set_volume! :mute
#     discussion.group.add_member!(user_thread_normal).set_volume! :mute
#     discussion.group.add_member!(user_thread_quiet).set_volume! :mute
#     discussion.group.add_member!(user_thread_mute).set_volume! :mute
#     discussion.group.add_member!(user_mentioned)
#     discussion.group.add_member!(user_poll_voted).set_volume! :normal
#     discussion.group.add_admin!(user_outcome_author).set_volume! :normal
#
#     DiscussionReader.for(discussion: discussion, user: user_thread_loud).set_volume! :loud
#     DiscussionReader.for(discussion: discussion, user: user_thread_normal).set_volume! :normal
#     DiscussionReader.for(discussion: discussion, user: user_thread_quiet).set_volume! :quiet
#     DiscussionReader.for(discussion: discussion, user: user_thread_mute).set_volume! :mute
#
#     # set membership volume - email for new discussions and proposals
#     discussion.group.add_member!(user_membership_loud).set_volume! :loud
#     discussion.group.add_member!(user_membership_normal).set_volume! :normal
#     discussion.group.add_member!(user_membership_quiet).set_volume! :quiet
#     discussion.group.add_member!(user_membership_mute).set_volume! :mute
#
#     # set email motion closing soon
#     discussion.group.add_member!(user_motion_closing_soon).set_volume! :mute
#   end
#
#   it 'new comment' do
#     users = Queries::UsersToEmailQuery.new_comment(comment)
#     users.should     include user_thread_loud
#     users.should     include user_membership_loud
#
#     users.should_not include user_left_group
#
#     users.should_not include user_membership_normal
#     users.should_not include user_thread_normal
#
#     users.should_not include user_membership_quiet
#     users.should_not include user_thread_quiet
#
#     users.should_not include user_membership_mute
#     users.should_not include user_thread_mute
#
#     users.should_not include comment.author
#     users.should_not include mentioned_user
#     users.should_not include comment.parent.author
#   end
#
#   it 'new_vote' do
#     users = Queries::UsersToEmailQuery.new_vote(vote)
#     users.should     include user_thread_loud
#     users.should     include user_membership_loud
#
#     users.should_not include user_membership_normal
#     users.should_not include user_thread_normal
#
#     users.should_not include user_membership_quiet
#     users.should_not include user_thread_quiet
#
#     users.should_not include user_membership_mute
#     users.should_not include user_thread_mute
#
#     users.should_not include vote.author
#   end
#
#   it 'new_discussion' do
#     users = Queries::UsersToEmailQuery.new_discussion(discussion)
#     users.should     include user_thread_loud
#     users.should     include user_membership_loud
#
#     users.should     include user_membership_normal
#     users.should     include user_thread_normal
#
#     users.should_not include user_membership_quiet
#     users.should_not include user_thread_quiet
#
#     users.should_not include user_membership_mute
#     users.should_not include user_thread_mute
#
#     users.should_not include discussion.author
#     users.should_not include user_mentioned
#   end
#
#   it 'new_motion' do
#     users = Queries::UsersToEmailQuery.new_motion(motion)
#     users.should     include user_thread_loud
#     users.should     include user_membership_loud
#
#     users.should     include user_membership_normal
#     users.should     include user_thread_normal
#
#     users.should_not include user_membership_quiet
#     users.should_not include user_thread_quiet
#
#     users.should_not include user_membership_mute
#     users.should_not include user_thread_mute
#
#     users.should_not include motion.author
#     users.should_not include user_mentioned
#   end
#
#   it 'motion_closing_soon' do
#     users = Queries::UsersToEmailQuery.motion_closing_soon(motion)
#     users.should     include user_thread_loud
#     users.should     include user_membership_loud
#
#     users.should     include user_membership_normal
#     users.should     include user_thread_normal
#
#     users.should_not include user_membership_quiet
#     users.should_not include user_thread_quiet
#
#     users.should_not include user_membership_mute
#     users.should_not include user_thread_mute
#
#     users.should     include user_motion_closing_soon
#   end
#
#   it 'motion_outcome' do
#     users = Queries::UsersToEmailQuery.motion_outcome_created(motion)
#     users.should     include user_thread_loud
#     users.should     include user_membership_loud
#
#     users.should     include user_membership_normal
#     users.should     include user_thread_normal
#
#     users.should_not include user_membership_quiet
#     users.should_not include user_thread_quiet
#
#     users.should_not include user_membership_mute
#     users.should_not include user_thread_mute
#
#     users.should_not include user_motion_closing_soon
#   end
#
#   it 'motion_closed' do
#     users = Queries::UsersToEmailQuery.motion_closed(motion)
#     users.should     include user_thread_loud
#     users.should     include user_membership_loud
#
#     users.should     include user_membership_normal
#     users.should     include user_thread_normal
#
#     users.should_not include user_membership_quiet
#     users.should_not include user_thread_quiet
#
#     users.should_not include user_membership_mute
#     users.should_not include user_thread_mute
#   end
#
#   describe 'polls' do
#
#     describe 'poll_create' do
#       it 'sends emails when make announcement is true' do
#         poll.make_announcement = true
#         users = Queries::UsersToEmailQuery.poll_create(poll)
#         users.should     include user_thread_loud
#         users.should     include user_membership_loud
#
#         users.should     include user_membership_normal
#         users.should     include user_thread_normal
#
#         users.should_not include user_membership_quiet
#         users.should_not include user_thread_quiet
#
#         users.should_not include user_membership_mute
#         users.should_not include user_thread_mute
#         users.should_not include poll.author
#       end
#
#       it 'does not send emails when make announcement is false' do
#         poll.make_announcement = false
#         users = Queries::UsersToEmailQuery.poll_create(poll)
#         users.should be_empty
#       end
#     end
#
#     describe 'poll_update' do
#       it 'sends emails to voters when make announcement is true' do
#         poll.make_announcement = true
#         users = Queries::UsersToEmailQuery.poll_update(poll)
#         users.should     include user_poll_voted
#         users.should_not include user_thread_loud
#       end
#
#       it 'does not send emails when make announcement is false' do
#         poll.make_announcement = false
#         users = Queries::UsersToEmailQuery.poll_update(poll)
#         users.should be_empty
#       end
#     end
#
#     describe 'poll_closing_soon' do
#       it 'sends emails to non-voters' do
#         users = Queries::UsersToEmailQuery.poll_closing_soon(poll)
#         users.should     include user_thread_loud
#         users.should     include user_membership_loud
#
#         users.should     include user_membership_normal
#         users.should     include user_thread_normal
#
#         users.should_not include user_membership_quiet
#         users.should_not include user_thread_quiet
#
#         users.should_not include user_membership_mute
#         users.should_not include user_thread_mute
#         users.should_not include user_poll_voted
#       end
#     end
#
#     describe 'outcome_create' do
#       it 'sends emails to listeners when make announcement is true' do
#         outcome.make_announcement = true
#         users = Queries::UsersToEmailQuery.outcome_create(outcome)
#         users.should     include user_thread_loud
#         users.should     include user_membership_loud
#
#         users.should     include user_membership_normal
#         users.should     include user_thread_normal
#
#         users.should_not include user_membership_quiet
#         users.should_not include user_thread_quiet
#
#         users.should_not include user_membership_mute
#         users.should_not include user_thread_mute
#         users.should_not include user_outcome_author
#       end
#
#       it 'does not send emails when make announcement is false' do
#         outcome.make_announcement = false
#         users = Queries::UsersToEmailQuery.outcome_create(outcome)
#         users.should be_empty
#       end
#     end
#
#     describe 'outcome_update' do
#       it 'sends emails to listeners when make announcement is true' do
#         outcome.make_announcement = true
#         users = Queries::UsersToEmailQuery.outcome_update(outcome)
#         users.should     include user_thread_loud
#         users.should     include user_membership_loud
#
#         users.should     include user_membership_normal
#         users.should     include user_thread_normal
#
#         users.should_not include user_membership_quiet
#         users.should_not include user_thread_quiet
#
#         users.should_not include user_membership_mute
#         users.should_not include user_thread_mute
#         users.should_not include user_outcome_author
#       end
#
#       it 'does not send emails when make announcement is false' do
#         outcome.make_announcement = false
#         users = Queries::UsersToEmailQuery.outcome_update(outcome)
#         users.should be_empty
#       end
#     end
#   end
# end
