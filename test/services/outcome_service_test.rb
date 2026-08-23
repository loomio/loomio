require 'test_helper'

class OutcomeServiceTest < ActiveSupport::TestCase
  inline_jobs "publishes a due review, and only once"
  setup do
    @user = users(:user)
    @group = groups(:group)

    @poll = PollService.create(params: {
      title: "Test Poll",
      poll_type: "proposal",
      poll_option_names: [ "Yes", "No" ],
      closing_at: 3.days.from_now,
      group_id: @group.id
    }, actor: @user)
    PollService.close(poll: @poll, actor: @user)

    @outcome = Outcome.create(
      poll: @poll,
      author: @user,
      statement: "Test outcome"
    )

    @new_outcome = Outcome.new(
      poll: @poll,
      author: @user,
      statement: "New outcome"
    )

    ActionMailer::Base.deliveries.clear
  end

  test "creates a new outcome" do
    reader = TopicReader.for(user: @user, topic: @poll.topic)
    reader.viewed!(@poll.topic.ranges)

    topic_item = nil
    assert_difference 'Outcome.count', 1 do
      topic_item = OutcomeService.create(outcome: @new_outcome, actor: @user)
    end

    assert_equal @new_outcome.statement, @poll.reload.current_outcome.statement
    assert_equal @new_outcome.author, @poll.current_outcome.author
    assert reader.reload.has_read?(topic_item.sequence_id)
    assert_equal 0, reader.unread_items_count
  end

  test "rolls back outcome creation when topic_item creation fails" do
    current_outcome = @poll.current_outcome

    assert_raises RuntimeError do
      TopicItems::OutcomeCreated.stub(:publish!, ->(**) { raise "topic_item failed" }) do
        OutcomeService.create(outcome: @new_outcome, actor: @user)
      end
    end

    assert_not Outcome.exists?(statement: @new_outcome.statement)
    assert_equal current_outcome, @poll.reload.current_outcome
  end

  test "outcome creation keeps its topic topic_item and creates one logical notification" do
    recipient = users(:member)
    TopicReader.for(user: recipient, topic: @poll.topic).set_volume!(:normal)

    topic_item = OutcomeService.create(
      outcome: @new_outcome,
      actor: @user,
      params: { recipient_user_ids: [ recipient.id ] }
    )
    notification = Notification.find_by!(kind: "outcome_created", subject: @new_outcome)

    assert_equal @poll.topic_id, topic_item.topic_id
    assert_equal [ recipient.id ], notification.recipient_user_ids
    assert_equal 1, Notification.where(kind: "outcome_created", subject: @new_outcome).count

    ResolveNotificationDeliveriesWorker.perform_now(notification.id)
    assert_equal %w[email in_app], notification.notification_deliveries.order(:channel).pluck(:channel)
  end

  test "outcome update creates an eventless logical notification" do
    recipient = users(:member)
    TopicReader.for(user: recipient, topic: @poll.topic).set_volume!(:normal)

    assert_no_difference -> { TopicItem.where(kind: "outcome_updated").count } do
      OutcomeService.update(
        outcome: @outcome,
        actor: @user,
        params: {
          statement: "Updated outcome",
          recipient_user_ids: [ recipient.id ]
        }
      )
    end
    notification = Notification.find_by!(kind: "outcome_updated", subject: @outcome)

    assert_equal [ recipient.id ], notification.recipient_user_ids

    ResolveNotificationDeliveriesWorker.perform_now(notification.id)
    assert_equal %w[email in_app], notification.notification_deliveries.order(:channel).pluck(:channel)
  end

  test "outcome update separates a newly mentioned recipient from update email delivery" do
    recipient = users(:member)
    recipient.update!(username: "outcomemention#{SecureRandom.hex(4)}")
    TopicReader.for(user: recipient, topic: @poll.topic).set_volume!(:normal)

    OutcomeService.update(
      outcome: @outcome,
      actor: @user,
      params: {
        statement: "Please review this, @#{recipient.username}",
        statement_format: "md",
        recipient_user_ids: [ recipient.id ]
      }
    )
    notification = Notification.find_by!(kind: "outcome_updated", subject: @outcome)

    assert_equal [ recipient.id ], notification.audience_values["newly_mentioned_user_ids"]
    ResolveNotificationDeliveriesWorker.perform_now(notification.id)
    assert_equal [ "in_app" ], notification.notification_deliveries.pluck(:channel)
    assert Notification.exists?(kind: "user_mentioned", subject: @outcome)
  end

  test "outcome update without a direct audience does not create a notification" do
    NotificationService.stub(:create!, ->(**) { raise "notification creation is not expected" }) do
      OutcomeService.update(
        outcome: @outcome,
        actor: @user,
        params: { statement: "Saved without a notification" }
      )
    end

    assert_equal "Saved without a notification", @outcome.reload.statement
    assert_not TopicItem.exists?(kind: "outcome_updated", itemable: @outcome)
  end

  test "outcome creation rolls back when notification creation fails" do
    current_outcome = @poll.current_outcome

    assert_raises RuntimeError do
      NotificationService.stub(:create!, ->(**) { raise "notification failed" }) do
        OutcomeService.create(
          outcome: @new_outcome,
          actor: @user,
          params: { recipient_user_ids: [ users(:member).id ] }
        )
      end
    end

    assert_not Outcome.exists?(statement: @new_outcome.statement)
    assert_equal current_outcome, @poll.reload.current_outcome
  end

  test "does not create an invalid outcome" do
    @new_outcome.statement = ""

    assert_difference 'Outcome.count', 0 do
      OutcomeService.create(outcome: @new_outcome, actor: @user)
    end
  end

  test "invitation rolls back a newly created recipient when notification creation fails" do
    email = "atomic-outcome-#{SecureRandom.hex(4)}@example.com"

    assert_raises RuntimeError do
      NotificationService.stub(:create!, ->(**) { raise "notification failed" }) do
        OutcomeService.invite(
          outcome: @outcome,
          actor: @user,
          params: { recipient_emails: [ email ] }
        )
      end
    end

    assert_not User.exists?(email: email)
  end

  test "publishes a due review, and only once" do
    @outcome.update(review_on: Date.today)

    ActionMailer::Base.deliveries.clear
    assert_difference "Notification.count", 1 do
      assert_no_difference -> { TopicItem.where(kind: "outcome_review_due").count } do
        OutcomeService.publish_review_due
      end
    end

    notification = Notification.find_by!(
      kind: "outcome_review_due",
      subject: @outcome
    )
    assert_not_nil notification.deliveries_generated_at
    assert_equal %w[email in_app], notification.notification_deliveries.order(:channel).pluck(:channel)

    assert_no_difference [ "Notification.count", "NotificationDelivery.count" ] do
      OutcomeService.publish_review_due
    end

    last_email = ActionMailer::Base.deliveries.last
    assert_includes last_email.to, @outcome.author.email
  end

  test "does not publish null review_on" do
    @outcome.update(review_on: nil)

    assert_no_difference -> { TopicItem.where(kind: "outcome_review_due").count } do
      OutcomeService.publish_review_due
    end
  end
end
