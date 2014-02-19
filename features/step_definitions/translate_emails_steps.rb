Given(/^"(.*?)" is a user with an English language preference$/) do |arg1|
  user = FactoryGirl.create :user, name: arg1,
                            email: "#{arg1}@example.org",
                            language_preference: "en"
end

Given(/^"(.*?)" is a user with a Spanish language preference$/) do |arg1|
  user = FactoryGirl.create :user, name: arg1,
                            email: "#{arg1}@example.org",
                            language_preference: "es"
end

Given(/^"(.*?)" is a user without a specified language preference$/) do |arg1|
  user = FactoryGirl.create :user, name: arg1,
                          email: "#{arg1}@example.org"
end

Given(/^"(.*?)" has created a new discussion$/) do |arg1|
  author = User.find_by_email("#{arg1}@example.org")
  group = FactoryGirl.create :group
  @discussion = create_discussion :group => group, author: author
end

Then(/^the new discussion email should be delivered to "(.*?)" in Spanish$/) do |arg1|
  user = User.find_by_email("#{arg1}@example.org")
  email = DiscussionMailer.new_discussion_created(@discussion, user)
  email.body.encoded.should include("Haz click")
end

Then(/^the new discussion email should be delivered to "(.*?)" in English$/) do |arg1|
  user = User.find_by_email("#{arg1}@example.org")
  email = DiscussionMailer.new_discussion_created(@discussion, user)
  snippet = I18n.t(:"email.create_discussion.intro", who: @discussion.author.name, which_group: @discussion.group.full_name, locale: "en")
  email.body.encoded.should include(snippet)
end

Given(/^"(.*?)" has created a new proposal$/) do |arg1|
  author = User.find_by_email("#{arg1}@example.org")
  group = FactoryGirl.create :group
  @discussion = create_discussion group: group
  @motion = FactoryGirl.create :motion, discussion: @discussion, author: author
end

Then(/^the new proposal email should be delivered to "(.*?)" in Spanish$/) do |arg1|
  user = User.find_by_email("#{arg1}@example.org")
  email = MotionMailer.new_motion_created(@motion, user)
  email.body.encoded.should include(I18n.t(:"help.have_your_say", locale: "es")[0..9])
end

Then(/^the new proposal email should be delivered to "(.*?)" in English$/) do |arg1|
  user = User.find_by_email("#{arg1}@example.org")
  email = MotionMailer.new_motion_created(@motion, user)
  email.body.encoded.should include(I18n.t(:"help.have_your_say", locale: "en"))
end

Given(/^"(.*?)" has blocked a proposal started by "(.*?)"$/) do |arg1, arg2|
  author = User.find_by_email("#{arg2}@example.org")
  group = FactoryGirl.create :group
  @discussion = create_discussion group: group
  motion = FactoryGirl.create :motion, discussion: @discussion, author: author
  user = User.find_by_email("#{arg1}@example.org")
  @vote = FactoryGirl.create :vote, position: "block",
                                    user_id: user.id,
                                    motion_id: motion.id
end

Then(/^the proposal blocked email should be delivered to "(.*?)" in Spanish$/) do |arg1|
  email = MotionMailer.motion_blocked(@vote)
  email.body.encoded.should include("Grupo")
end

Then(/^the proposal blocked email should be delivered to "(.*?)" in English$/) do |arg1|
  email = MotionMailer.motion_blocked(@vote)
  email.body.encoded.should include(I18n.t(:group, locale: "en"))
end

Given(/^the proposal started by "(.*?)" is closing soon$/) do |arg1|
  author = User.find_by_email("#{arg1}@example.org")
  group = FactoryGirl.create :group
  @discussion = create_discussion group: group
  @motion = FactoryGirl.create :motion, discussion: @discussion, author: author, closing_at: Time.now + 1.hour
end

Then(/^"(.*?)" should receive the proposal closing soon email in English$/) do |arg1|
  user = User.find_by_email("#{arg1}@example.org")
  email = UserMailer.motion_closing_soon(user, @motion)
  email.body.encoded.should include(I18n.t(:"email.proposal_closing_soon.closes_at", locale: "en"))
end

Then(/^"(.*?)" should receive the proposal closing soon email in Spanish$/) do |arg1|
  user = User.find_by_email("#{arg1}@example.org")
  email = UserMailer.motion_closing_soon(user, @motion)
  email.body.encoded.should include(I18n.t(:"email.proposal_closing_soon.closes_at", locale: "es"))
end

Given(/^"(.*?)" has closed their proposal$/) do |arg1|
  author = User.find_by_email("#{arg1}@example.org")
  group = FactoryGirl.create :group
  @discussion = create_discussion group: group
  @motion = FactoryGirl.create :motion, discussion: @discussion, author: author
  MotionService.close_by_user(@motion, author)
end

Given(/^"(.*?)" has set a proposal outcome$/) do |arg1|
  author = User.find_by_email("#{arg1}@example.org")
  motion_params = {outcome: 'This is what we do.'}
  MotionService.create_outcome(@motion, motion_params, author)
end

Then(/^the proposal closed email should be delivered to "(.*?)" in Spanish$/) do |arg1|
  email = MotionMailer.motion_closed(@motion, "#{arg1}@example.org")
  email.body.encoded.should include(I18n.t("email.proposal_closed.specify_outcome_and_notify_group", locale: "es")[0..23])
end

Then(/^the proposal closed email should be delivered to "(.*?)" in English$/) do |arg1|
  email = MotionMailer.motion_closed(@motion, "#{arg1}@example.org")
  email.body.encoded.should include(I18n.t("email.proposal_closed.specify_outcome_and_notify_group", locale: "en"))
end

Then(/^the proposal outcome email should be delivered to "(.*?)" in Spanish$/) do |arg1|
  email = MotionMailer.motion_outcome_created(@motion, User.find_by_name(arg1))
  email.body.encoded.should include(I18n.t("outcome", locale: "es"))
end

Then(/^the proposal outcome email should be delivered to "(.*?)" in English$/) do |arg1|
  email = MotionMailer.motion_outcome_created(@motion, User.find_by_name(arg1))
  email.body.encoded.should include(I18n.t("outcome", locale: "en"))
end

When(/^"(.*?)" requests membership to a group$/) do |arg1|
  user = User.find_by_email("#{arg1}@example.org")
  group = FactoryGirl.create :group
  @membership_request = FactoryGirl.create :membership_request, group: group, requestor: user
end

Then(/^the membership request email should be delivered to "(.*?)" in Spanish$/) do |arg1|
  email = GroupMailer.membership_request(User.find_by_name(arg1), @membership_request)
  email.body.encoded.should include(I18n.t("email.membership_request.view_group", locale: "es")[0, 5])
end

Then(/^the membership request email should be delivered to "(.*?)" in English$/) do |arg1|
  email = GroupMailer.membership_request(User.find_by_name(arg1), @membership_request)
  email.body.encoded.should include(I18n.t("email.membership_request.view_group", locale: "en"))
end

When(/^"(.*?)" approves "(.*?)"s group membership request$/) do |arg1, arg2|
  admin = User.find_by_email("#{arg1}@example.org")
  user = User.find_by_email("#{arg2}@example.org")
  group = FactoryGirl.create :group
  group.add_admin!(admin)
  @membership_request = FactoryGirl.create :membership_request, group: group, requestor: user
  @email = UserMailer.group_membership_approved(user, group)
end

Then(/^the group membership request approved email should be delivered in Spanish$/) do
  @email.body.encoded.should include("Haz click")
end

Then(/^the group membership request approved email should be delivered in English$/) do
  @email.body.encoded.should include(I18n.t("email.view_group", locale: "en"))
end

When(/^the daily activity email is sent$/) do
  user = FactoryGirl.create :user
  group = FactoryGirl.create :group
  discussion = create_discussion group: group
  @since_time = 24.hours.ago
  @results = CollectsRecentActivityByGroup.new(user, since: @since_time).results
end

Then(/^"(.*?)" should receive the daily activity email in Spanish$/) do |arg1|
  user = User.find_by_email("#{arg1}@example.org")
  email = UserMailer.daily_activity(user, @results, @since_time)
  email.body.encoded.should include(I18n.t("email.daily_activity.heading", locale: "es"))
end

Then(/^"(.*?)" should receive the daily activity email in English$/) do |arg1|
  user = User.find_by_email("#{arg1}@example.org")
  email = UserMailer.daily_activity(user, @results, @since_time)
  email.body.encoded.should include(I18n.t("email.daily_activity.heading", locale: "en"))
end

When(/^"(.*?)" mentions "(.*?)" in a comment$/) do |arg1, arg2|
  comment_author = User.find_by_email("#{arg1}@example.org")
  @mentioned_user = User.find_by_email("#{arg2}@example.org")
  @comment = FactoryGirl.create :comment, user_id: comment_author.id, body: "hey @#{arg2} whuddup"
end

Then(/^"(.*?)" should receive the mention email in Spanish$/) do |arg1|
  user = User.find_by_email("#{arg1}@example.org")
  email = UserMailer.mentioned(user, @comment)
  email.body.encoded.should include("mencionado")
end

Then(/^"(.*?)" should receive the mention email in English$/) do |arg1|
  user = User.find_by_email("#{arg1}@example.org")
  email = UserMailer.mentioned(user, @comment)
  email.body.encoded.should include(I18n.t("email.mentioned.intro", locale: "en"))
end

When(/^"(.*?)" requests to join a group administered by "(.*?)"$/) do |arg1, arg2|
  user = User.find_by_email("#{arg1}@example.org")
  admin = User.find_by_email("#{arg2}@example.org")
  @group = FactoryGirl.create :group
  @group.add_admin!(admin)
end

Then(/^"(.*?)" should receive the membership request approval email in English$/) do |arg1|
  user = User.find_by_email("#{arg1}@example.org")
  email = UserMailer.group_membership_approved(user, @group)
  email.body.encoded.should include(I18n.t("email.view_group", locale: "en"))
end

Then(/^"(.*?)" should receive the membership request approval email in Spanish$/) do |arg1|
  user = User.find_by_email("#{arg1}@example.org")
  email = UserMailer.group_membership_approved(user, @group)
  email.body.encoded.should include("Haz click")
end

When(/^"(.*?)" makes an announcement to the group$/) do |arg1|
  @sender = User.find_by_email("#{arg1}@example.org")
  @group = FactoryGirl.create :group
end

Then(/^"(.*?)" should receive the group email in English$/) do |arg1|
  recipient = User.find_by_email("#{arg1}@example.org")
  email = GroupMailer.group_email(@group, @sender, "Subject", "message", recipient)
  email.body.encoded.should include(I18n.t("email.view_group", locale: "en"))
end

Then(/^"(.*?)" should receive the group email in Spanish$/) do |arg1|
  recipient = User.find_by_email("#{arg1}@example.org")
  email = GroupMailer.group_email(@group, @sender, "Subject", "message", recipient)
  email.body.encoded.should include("Haz click")
end

Given(/^"(.*?)" is a logged\-out user$/) do |arg1|
  @logged_out_user_email = "#{arg1}@example.org"
end

When(/^their browser header indicates a Spanish language preference$/) do
  page.driver.headers = { "Accept-Language" => "es" }
end

Then(/^they should receive the group request verification email in Spanish$/) do
  group_request = GroupRequest.first
  email = StartGroupMailer.verification(group_request)
  email.body.encoded.should include("Grupo")
end
