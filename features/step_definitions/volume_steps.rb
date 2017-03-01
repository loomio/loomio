Given(/^Loud Larry is following everything in the group by email$/) do
  @loud_larry = FactoryGirl.create(:user,
                                   name: 'Loud Larry',
                                   email_missed_yesterday: false,
                                   email_on_participation: false,
                                   email_when_proposal_closing_soon: false)
  @group.add_member!(@loud_larry).set_volume!(:loud)
end

Given(/^Normal Norman gets important events emailed as they happen$/) do
  @normal_norman = FactoryGirl.create(:user,
                                      name: 'Normal Norman',
                                      email_missed_yesterday: false,
                                      email_on_participation: false,
                                      email_when_proposal_closing_soon: false)
  @group.add_member!(@normal_norman).set_volume! :normal
end

Given(/^Quiet Quincey want to catch up by digest email$/) do
  @quiet_quincey = FactoryGirl.create(:user,
                                      name: 'Quiet Quincey',
                                      email_missed_yesterday: false,
                                      email_on_participation: false,
                                      email_when_mentioned: false,
                                      email_when_proposal_closing_soon: false)
  @group.add_member!(@quiet_quincey).set_volume!(:quiet)
end

Given(/^Mute megan mutes everything\.$/) do
  @mute_megan = FactoryGirl.create(:user,
                                   username: 'megan',
                                   name: 'Mute Megan',
                                   email_missed_yesterday: false,
                                   email_on_participation: false,
                                   email_when_mentioned: true,
                                   email_when_proposal_closing_soon: false)
  @group.add_member!(@mute_megan).set_volume!(:mute)
end

Given(/^Hermit Harry turns off all emails\.$/) do
  @hermit_harry = FactoryGirl.create(:user,
                                     username: 'harry',
                                     name: 'Hermit Harry',
                                     email_missed_yesterday: false,
                                     email_on_participation: false,
                                     email_when_mentioned: false,
                                     email_when_proposal_closing_soon: false)
  @group.add_member!(@hermit_harry).set_volume!(:mute)
end

Given(/^Closing Soonsan mutes everything but wants to hear when proposals are closing and when mentioned\.$/) do
  @closing_soonsan = FactoryGirl.create(:user,
                                   name: 'Closing Soonsan',
                                   email_missed_yesterday: false,
                                   email_on_participation: false,
                                   email_when_mentioned: false,
                                   email_when_proposal_closing_soon: true)
  @group.add_member!(@closing_soonsan).set_volume!(:mute)
end

When(/^I start a new discussion$/) do
  reset_mailer
  @discussion = FactoryGirl.build :discussion, author: @user, group: @group, make_announcement: true
  @event = DiscussionService.create(discussion: @discussion, actor: @discussion.author)
end

Then(/^"(.*?)" +should be emailed$/) do |name|
  email = User.find_by_name(name).email
  step "\"#{email}\" should receive an email"
end

Then(/^"(.*?)" +should not be emailed$/) do |name|
  email = User.find_by_name(name).email
  step "\"#{email}\" should receive no emails"
end

Then(/^I should not be emailed$/) do
  email = @user.email
  step "\"#{email}\" should receive no emails"
end

When(/^I add a comment$/) do
  step 'I start a new discussion'
  reset_mailer
  @comment = FactoryGirl.build :comment, discussion: @discussion, body: "yea i know", author: @user
  @add_comment_event = CommentService.create(comment: @comment, actor: @user)
end

When(/^I mention Master Mentions Only$/) do
  step 'I start a new discussion'
  reset_mailer
  @comment = FactoryGirl.build :comment, discussion: @discussion, author: @user,
                               body: "yea @#{@master_mentions_only.username}"
  @add_comment_event = CommentService.create(comment: @comment, actor: @user)

  @user_mentioned_event = Event.where(kind: 'user_mentioned').last
end
When(/^someone else creates a discussion in my group$/) do
  @discussion = FactoryGirl.build(:discussion, group: @group)
  DiscussionService.create(discussion: @discussion, actor: @discussion.author)
end

Then(/^I should not be following the discussion$/) do
  @discussion_reader = DiscussionReader.for(discussion: @discussion,
                                            user: @user)
  @discussion_reader.volume_is_loud?.should be false
end

When(/^I create a discussion in my group$/) do
  @discussion = FactoryGirl.build(:discussion, group: @group, author: @user)
  DiscussionService.create(discussion: @discussion, actor: @discussion.author)
end

Then(/^I should be following the discussion$/) do
  @discussion.reload
  @discussion_reader = DiscussionReader.for(discussion: @discussion,
                                            user: @user)
  @discussion_reader.volume_is_loud?.should be true
end

Given(/^I am autofollowing new discussions in my group$/) do
  @user.memberships.find_by_group_id(@group.id).set_volume! :loud
end

When(/^I comment in the discussion I'm following on participation$/) do
  @user.update_attribute(email_on_participation: true)
  @comment = FactoryGirl.build(:comment, discussion: @discussion, author: @user)
  CommentService.create(comment: @comment, actor: @user)
end

When(/^I like a comment in the discussion I'm following on participation$/) do
  @user.update_attribute(email_on_participation: true)
  @comment = FactoryGirl.create(:comment, discussion: @discussion)
  CommentService.like(comment: @comment, actor: @user)
end

When(/^I comment on the discussion, mentioning Rich$/) do
  @rich = FactoryGirl.create(:user, username: 'rich')
  @discussion.group.add_member!(@rich)
  @comment = FactoryGirl.build(:comment,
                               discussion: @discussion,
                               author: @user,
                               body: 'hi @rich')
  CommentService.create(comment: @comment, actor: @user)
end

Then(/^I should be following it$/) do
  @discussion.reload
  @discussion_reader = DiscussionReader.for(discussion: @discussion,
                                            user: @user)

  @discussion_reader.volume_is_loud?.should be true
end


Then(/^Rich should be following the discussion$/) do
  @discussion_reader = DiscussionReader.for(discussion: @discussion,
                                            user: @rich)

  @discussion_reader.volume_is_loud?.should be true
end

Given(/^I update the title$/) do
  DiscussionService.update(discussion: @discussion, actor: @user, params: {title: "updated"})
end

Then(/^my followed threads should include the discussion$/) do
  @discussions = Queries::VisibleDiscussions.new(user: @user, groups: @user.groups).not_muted
  @discussions.should include(@discussion)
end

Given(/^I am following by default in a group$/) do
  @group.membership_for(@user).set_volume! :loud
end

When(/^there is a discussion created by someone in the group$/) do
  @discussion = FactoryGirl.build(:discussion, group: @group)
  DiscussionService.create(discussion: @discussion, actor: @discussion.author)
end

Given(/^I have set my preferences to email me activity I'm following$/) do
  @user.update_attribute(:email_on_participation, true)
end

Given(/^I am following the group$/) do
  @group.membership_for(@user).set_volume! :loud
end

Given(/^I am not following the group$/) do
  @group.membership_for(@user).set_volume! :normal
end

Given(/^I click "(.*?)" on the group page$/) do |arg1|
  visit group_path(@group)
  click_on arg1
end

Given(/^I click 'Following' on the group page$/) do
  visit group_path(@group)
  find('.cuke-unfollow-group').click
end

Then(/^I should get an email about the new discussion$/) do
  ActionMailer::Base.deliveries.last.to.should include @user.email
  expect(ActionMailer::Base.deliveries.last.subject).to eq @discussion.title
end

Then(/^I should not get an email about the new discussion$/) do
  @current_user = @user
  step('I should receive no emails')
end

Given(/^there is a discussion I have never seen before$/) do
  @discussion = FactoryGirl.build :discussion, group: @group
  DiscussionService.create(discussion: @discussion, actor: @discussion.author)
end

Given(/^there are no emails waiting for me$/) do
  ActionMailer::Base.deliveries = []
end

Then(/^I should be following new discussions by default$/) do
  expect(@group.membership_for(@user).volume).to eq 'loud'
end

Then(/^I should not be following discussions by default$/) do
  expect(@group.membership_for(@user).volume).to eq 'normal'
end

Given(/^I get mentioned in a discussion$/) do
  @comment = FactoryGirl.build(:comment, discussion: @discussion, body: "hi @#{@user.username}")
  CommentService.create(comment: @comment, actor: @comment.author)
end

Given(/^there is a discussion I have unfollowed$/) do
  @discussion = FactoryGirl.build :discussion, group: @group
  DiscussionService.create(discussion: @discussion, actor: @discussion.author)
  DiscussionReader.for(discussion: @discussion, user: @user).unfollow!
end

Given(/^there is a discussion I am following$/) do
  @discussion = FactoryGirl.build :discussion, group: @group
  DiscussionService.create(discussion: @discussion, actor: @discussion.author)
  DiscussionReader.for(discussion: @discussion, user: @user).follow!
end

When(/^there is a subsequent comment in the discussion$/) do
  @comment = FactoryGirl.build(:comment, discussion: @discussion, body: "yea i know")
  CommentService.create(comment: @comment, actor: @comment.author)
end

Then(/^I should be emailed the comment$/) do
  @current_user = @user
  step("I open the email with text \"#{@comment.body}\"")
end

Given(/^I click 'Following' on the discussion page$/) do
  visit discussion_path @discussion
  click_on "Following"
end

Then(/^I should get a mentioned notification$/) do
  expect(@user.notifications.last.event.kind).to eq 'user_mentioned'
end

Given(/^there is a discussion I am not following$/) do
  @discussion = FactoryGirl.build :discussion, group: @group
  DiscussionService.create(discussion: @discussion, actor: @discussion.author)
end

Given(/^I click 'Not Following' on the discussion page$/) do
  visit discussion_path(@discussion)
  find('.cuke-follow').click
end

When(/^I am on the dashboard$/) do
  visit dashboard_url
end

Then(/^I should see both discussions$/) do
  pending # express the regexp above with the code you wish you had
end

When(/^I filter to only show followed content$/) do
  pending # express the regexp above with the code you wish you had
end

Then(/^I should only see the followed discussion$/) do
  pending # express the regexp above with the code you wish you had
end



Then(/^"(.*?)" should be notified but not emailed about the new mention$/) do |name|
  step "\"#{name}\" should not be emailed"
  mentioned_user = User.find_by_name(name)
  @user_mentioned_event.notifications.where(user_id: mentioned_user.id).should exist
end

Then(/^"(.*?)" should be emailed and notified about the proposal closing soon$/) do |name|
  step "\"#{name}\" should be emailed"
  user = User.find_by_name(name)
  @motion_closing_soon_event.notifications.where(user_id: user.id).should exist
end

Then(/^"(.*?)" should be notified but not emailed about the proposal closing soon$/) do |name|
  step "\"#{name}\" should not be emailed"
  user = User.find_by_name(name)
  @motion_closing_soon_event.notifications.where(user_id: user.id).should exist
end

Then(/^I should be emailed and notified that the proposal closed$/) do
  step "\"#{@user.name}\" should be emailed"
  @motion_closed_event.notifications.where(user_id: @user.id).should exist
end

Then(/^I should be emailed and notified about the proposal closing soon$/) do
  step "\"#{@user.name}\" should be emailed and notified about the proposal closing soon"
end

When(/^I start a new proposal$/) do
  step 'I start a new discussion'
  reset_mailer
  @motion = FactoryGirl.build :motion, discussion: @discussion, author: @user
  @start_motion_event = MotionService.create(motion: @motion, actor: @user)
end

When(/^I vote on the proposal$/) do
  step 'I start a new proposal'
  reset_mailer
  @vote = FactoryGirl.build :vote, motion: @motion, user: @user
  @cast_vote_event = VoteService.create vote: @vote, actor: @user
end

When(/^my proposal is about to close$/) do
  step 'I start a new discussion'
  @motion = FactoryGirl.build :motion, discussion: @discussion, author: @user
  MotionService.create(motion: @motion, actor: @user)
  reset_mailer
  @motion_closing_soon_event = Events::MotionClosingSoon.publish! @motion
end

When(/^my proposal closes$/) do
  step 'I start a new proposal'
  reset_mailer
  @motion_closed_event = MotionService.close(@motion)
end

Given(/^a group with an existing thread$/) do
  @group = FactoryGirl.create :group
  @discussion = FactoryGirl.create :discussion, group: @group
end

When(/^I join and follow the group$/) do
  @user = FactoryGirl.create :user
  @group.add_member! @user
  @user.memberships.where(group_id: @group.id).first.follow_by_default!
end

Then(/^I should not see anything in my followed threads$/) do
  Queries::VisibleDiscussions.new(user: @user, groups: [@group]).following.discussion_newer_than_membership.should be_empty
end

When(/^there is a new thread started in the group$/) do
  @discussion = FactoryGirl.create(:discussion, group: @group)
end

Then(/^I should see the thread in my followed threads$/) do
  Queries::VisibleDiscussions.new(user: @user, groups: [@group]).following.should include @discussion
end

Then(/^I should see the thread in my unread threads$/) do
  Queries::VisibleDiscussions.new(user: @user, groups: [@group]).unread.should include @discussion
end

When(/^there is a new comment in the thread$/) do
  @comment = FactoryGirl.build(:comment, discussion: @discussion)
  CommentService.create(comment: @comment, actor: @comment.author)
end

Then(/^I should not see anything in my unread threads$/) do
  Queries::VisibleDiscussions.new(user: @user, groups: [@group]).unread.discussion_newer_than_membership.should be_empty
end

When(/^I set a proposal outcome$/) do
  @discussion = FactoryGirl.create :discussion, group: @group
  @motion = FactoryGirl.create :motion, discussion: @discussion
  @motion.outcome = "success"
  @motion.outcome_author = @user
  event =  MotionService.create_outcome(motion: @motion, actor: @motion.author, params: {outcome: 'yes ok'})
end

When(/^I mention Mute Megan$/) do
  @discussion = FactoryGirl.create :discussion, group: @group
  comment = FactoryGirl.build(:comment, author: @user, discussion: @discussion, body: 'hi @megan')
  CommentService.create(comment: comment, actor: @user)
end

When(/^I mention Hermit Harry$/) do
  @discussion = FactoryGirl.create :discussion, group: @group
  comment = FactoryGirl.build(:comment, author: @user, discussion: @discussion, body: 'hi @harry')
  CommentService.create(comment: comment, actor: @user)
end
