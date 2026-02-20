require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  setup do
    hex = SecureRandom.hex(4)
    @user = User.create!(name: "mailuser#{hex}", email: "mailuser#{hex}@example.com", username: "mailuser#{hex}", email_verified: true)
    @inviter = User.create!(name: "mailinviter#{hex}", email: "mailinviter#{hex}@example.com", username: "mailinviter#{hex}", email_verified: true)
    @group = Group.new(name: "Mailgroup #{hex}", group_privacy: 'secret', handle: "mailgroup#{hex}")
    @group.creator = @inviter
    @group.save!
    @group.add_admin!(@inviter)
    ActionMailer::Base.deliveries.clear
  end

  # Membership request approved
  test "membership_request_approved renders receiver email" do
    membership = @group.add_member!(@user)
    event = Events::MembershipRequestApproved.create!(kind: 'membership_request_approved', user: @user, eventable: membership)
    mail = UserMailer.membership_request_approved(@user.id, event.id)
    assert_equal [@user.email], mail.to
  end

  test "membership_request_approved renders sender email" do
    membership = @group.add_member!(@user)
    event = Events::MembershipRequestApproved.create!(kind: 'membership_request_approved', user: @user, eventable: membership)
    mail = UserMailer.membership_request_approved(@user.id, event.id)
    assert_includes mail.from, ApplicationMailer::NOTIFICATIONS_EMAIL_ADDRESS
  end

  test "membership_request_approved assigns correct reply_to" do
    membership = @group.add_member!(@user)
    event = Events::MembershipRequestApproved.create!(kind: 'membership_request_approved', user: @user, eventable: membership)
    mail = UserMailer.membership_request_approved(@user.id, event.id)
    assert_equal [@group.admin_email], mail.reply_to
  end

  test "membership_request_approved renders the subject" do
    membership = @group.add_member!(@user)
    event = Events::MembershipRequestApproved.create!(kind: 'membership_request_approved', user: @user, eventable: membership)
    mail = UserMailer.membership_request_approved(@user.id, event.id)
    assert_equal "Your request to join #{@group.full_name} has been approved", mail.subject
  end

  test "membership_request_approved body contains group handle" do
    membership = @group.add_member!(@user)
    event = Events::MembershipRequestApproved.create!(kind: 'membership_request_approved', user: @user, eventable: membership)
    mail = UserMailer.membership_request_approved(@user.id, event.id)
    assert_match @group.handle, mail.body.encoded
  end

  # User added to group
  test "user_added_to_group renders the subject" do
    membership = @group.add_member!(@user)
    membership.update_columns(inviter_id: @inviter.id)
    event = Events::UserAddedToGroup.create!(kind: 'user_added_to_group', user: @inviter, eventable: membership)
    mail = UserMailer.user_added_to_group(@user.id, event.id)
    assert_equal "#{@inviter.name} has added you to #{@group.full_name} on #{AppConfig.theme[:site_name]}", mail.subject
  end

  # Catch up
  test "sends a catch up email when there is unread content" do
    @user.update!(email_catch_up_day: 7)
    @group.add_member!(@user)
    author = @inviter
    discussion = DiscussionService.create(params: { title: "Catch up #{SecureRandom.hex(4)}", group_id: @group.id }, actor: author)[:discussion]
    comment = Comment.new(parent: discussion, body: "catch up comment")
    CommentService.create(comment: comment, actor: author)
    ActionMailer::Base.deliveries.clear

    assert_difference 'ActionMailer::Base.deliveries.count', 1 do
      UserMailer.catch_up(@user.id).deliver_now
    end
  end

  test "does not send catch up when there is no unread content" do
    @user.update!(email_catch_up_day: 7)
    @group.add_member!(@user)
    ActionMailer::Base.deliveries.clear

    assert_no_difference 'ActionMailer::Base.deliveries.count' do
      UserMailer.catch_up(@user.id).deliver_now
    end
  end

  test "does not send catch up if unsubscribed" do
    @user.update!(email_catch_up_day: nil, time_zone: 'Pacific/Tarawa')
    @group.add_member!(@user)
    author = @inviter

    travel_to Time.now.in_time_zone(@user.time_zone).next_occurring(:monday).change(hour: 6) do
      discussion = DiscussionService.create(params: { title: "CatchupUnsub #{SecureRandom.hex(4)}", group_id: @group.id }, actor: author)[:discussion]
      ActionMailer::Base.deliveries.clear

      assert_no_difference 'ActionMailer::Base.deliveries.count' do
        SendDailyCatchUpEmailWorker.new.perform
      end
    end
  end

  test "emails daily when catch_up_day is 7" do
    @user.update!(email_catch_up_day: 7, time_zone: 'Pacific/Tarawa')
    @group.add_member!(@user)
    author = @inviter

    travel_to Time.now.in_time_zone(@user.time_zone).next_occurring(:monday).change(hour: 6) do
      discussion = DiscussionService.create(params: { title: "CatchupDaily #{SecureRandom.hex(4)}", group_id: @group.id }, actor: author)[:discussion]
      ActionMailer::Base.deliveries.clear

      assert_difference 'ActionMailer::Base.deliveries.count', 1 do
        SendDailyCatchUpEmailWorker.new.perform
      end
    end
  end

  test "emails mondays when catch_up_day is 1 at 6am" do
    @user.update!(email_catch_up_day: 1, time_zone: 'Pacific/Tarawa')
    @group.add_member!(@user)
    author = @inviter

    travel_to Time.now.in_time_zone(@user.time_zone).next_occurring(:monday).change(hour: 6) do
      discussion = DiscussionService.create(params: { title: "CatchupMon #{SecureRandom.hex(4)}", group_id: @group.id }, actor: author)[:discussion]
      ActionMailer::Base.deliveries.clear

      assert_difference 'ActionMailer::Base.deliveries.count', 1 do
        SendDailyCatchUpEmailWorker.new.perform
      end
    end
  end

  test "does not email mondays when catch_up_day is 1 at 5am" do
    @user.update!(email_catch_up_day: 1, time_zone: 'Pacific/Tarawa')
    @group.add_member!(@user)
    author = @inviter

    travel_to Time.now.in_time_zone(@user.time_zone).next_occurring(:monday).change(hour: 5) do
      discussion = DiscussionService.create(params: { title: "CatchupNo5am #{SecureRandom.hex(4)}", group_id: @group.id }, actor: author)[:discussion]
      ActionMailer::Base.deliveries.clear

      assert_no_difference 'ActionMailer::Base.deliveries.count' do
        SendDailyCatchUpEmailWorker.new.perform
      end
    end
  end

  # Group export ready
  test "group_export_ready sends email with download link" do
    document = Document.new(author: @user, title: "export.csv")
    document.file.attach(io: StringIO.new("csv,data"), filename: "export.csv", content_type: "text/csv")
    document.save!

    mail = UserMailer.group_export_ready(@user.id, @group.full_name, document.id)
    assert_equal [@user.email], mail.to
    assert_equal I18n.t("user_mailer.group_export_ready.subject", group_name: @group.full_name), mail.subject
    assert_match "/rails/active_storage/blobs/", mail.body.encoded
  end

  test "does not email mondays when tuesday" do
    @user.update!(email_catch_up_day: 1, time_zone: 'Pacific/Tarawa')
    @group.add_member!(@user)
    author = @inviter

    travel_to Time.now.in_time_zone(@user.time_zone).next_occurring(:tuesday).change(hour: 6) do
      discussion = DiscussionService.create(params: { title: "CatchupTues #{SecureRandom.hex(4)}", group_id: @group.id }, actor: author)[:discussion]
      ActionMailer::Base.deliveries.clear

      assert_no_difference 'ActionMailer::Base.deliveries.count' do
        SendDailyCatchUpEmailWorker.new.perform
      end
    end
  end
end
