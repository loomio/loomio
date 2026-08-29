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

  # Catch up
  test "sends a catch up email when there is unread content" do
    @user.update!(email_catch_up_day: 7)
    @group.add_member!(@user)
    author = @inviter
    discussion = DiscussionService.create(params: { title: "Catch up #{SecureRandom.hex(4)}", group_id: @group.id }, actor: author)
    comment = Comment.new(parent: discussion, body: "catch up comment")
    CommentService.create(comment: comment, actor: author)
    ActionMailer::Base.deliveries.clear

    assert_difference 'ActionMailer::Base.deliveries.count', 1 do
      UserMailer.catch_up(@user.id).deliver_now
    end
  end

  test "catch up email includes discussions the user is a guest of" do
    @user.update!(email_catch_up_day: 7)
    # @user is NOT a member of @group — only a guest on the discussion
    title = "Guest catchup #{SecureRandom.hex(4)}"
    discussion = DiscussionService.create(params: { title: title, group_id: @group.id }, actor: @inviter)
    discussion.topic.add_guest!(@user, @inviter)
    CommentService.create(comment: Comment.new(parent: discussion, body: "a comment"), actor: @inviter)
    ActionMailer::Base.deliveries.clear

    assert_difference 'ActionMailer::Base.deliveries.count', 1 do
      UserMailer.catch_up(@user.id).deliver_now
    end

    assert_includes ActionMailer::Base.deliveries.last.body.encoded, title
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
      DiscussionService.create(params: { title: "CatchupUnsub #{SecureRandom.hex(4)}", group_id: @group.id }, actor: author)
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
      DiscussionService.create(params: { title: "CatchupDaily #{SecureRandom.hex(4)}", group_id: @group.id }, actor: author)
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
      DiscussionService.create(params: { title: "CatchupMon #{SecureRandom.hex(4)}", group_id: @group.id }, actor: author)
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
      DiscussionService.create(params: { title: "CatchupNo5am #{SecureRandom.hex(4)}", group_id: @group.id }, actor: author)
      ActionMailer::Base.deliveries.clear

      assert_no_difference 'ActionMailer::Base.deliveries.count' do
        SendDailyCatchUpEmailWorker.new.perform
      end
    end
  end

  # Group export ready
  test "group_export_ready sends email with download link" do
    blob = ActiveStorage::Blob.create_and_upload!(
      io: StringIO.new("csv,data"),
      filename: "export.csv",
      content_type: "text/csv"
    )

    mail = UserMailer.group_export_ready(@user.id, @group.full_name, blob.signed_id)
    assert_equal [@user.email], mail.to
    assert_equal I18n.t(
      "user_mailer.group_export_ready.subject",
      group_name: @group.full_name,
      locale: @user.locale
    ), mail.subject
    assert_match "/rails/active_storage/blobs/", mail.body.encoded
  end

  test "does not email mondays when tuesday" do
    @user.update!(email_catch_up_day: 1, time_zone: 'Pacific/Tarawa')
    @group.add_member!(@user)
    author = @inviter

    travel_to Time.now.in_time_zone(@user.time_zone).next_occurring(:tuesday).change(hour: 6) do
      DiscussionService.create(params: { title: "CatchupTues #{SecureRandom.hex(4)}", group_id: @group.id }, actor: author)
      ActionMailer::Base.deliveries.clear

      assert_no_difference 'ActionMailer::Base.deliveries.count' do
        SendDailyCatchUpEmailWorker.new.perform
      end
    end
  end
end
