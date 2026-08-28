require 'test_helper'

class StanceServiceTest < ActiveSupport::TestCase
  inline_jobs "visible stance topic item sends loud subscriber email without a notification row"

  setup do
    @user = users(:user)
    @admin = users(:admin)
    @alien = users(:alien)
    @group = groups(:group)

    @poll = PollService.create(params: {
      title: 'Test Poll',
      poll_type: 'proposal',
      closing_at: 3.days.from_now,
      group_id: @group.id,
      poll_option_names: ['Agree', 'Disagree']
    }, actor: @admin)
  end

  # -- Create --

  test "creates a new stance" do
    reader = TopicReader.for(user: @user, topic: @poll.topic)
    reader.viewed!(@poll.topic.ranges)

    stance = @poll.stances.undecided.find_by!(participant_id: @user.id, latest: true)
    stance.choice = @poll.poll_option_names.first
    stance.reason = "I agree"

    topic_item = nil
    created_stance = StanceService.create(stance: stance, actor: @user) { |created_topic_item| topic_item = created_topic_item }
    assert_equal stance, created_stance
    assert_kind_of TopicItem, topic_item
    assert reader.reload.has_read?(topic_item.sequence_id)
    assert_equal 0, reader.unread_items_count
    assert_not Notification.about(stance).exists?(kind: "stance_created")
  end

  test "visible stance topic item sends loud subscriber email without a notification row" do
    subscriber = users(:member)
    TopicReader.for(user: subscriber, topic: @poll.topic).set_volume!(:loud)
    stance = @poll.stances.undecided.find_by!(participant_id: @user.id, latest: true)
    stance.choice = @poll.poll_option_names.first
    stance.reason = "Visible response"

    ActionMailer::Base.deliveries.clear
    topic_item = nil
    StanceService.create(stance: stance, actor: @user) { |created_topic_item| topic_item = created_topic_item }
    PublishSubscriberEmailsTopicItemWorker.perform_now(topic_item.id)

    assert_includes ActionMailer::Base.deliveries.flat_map(&:to), subscriber.email
    assert_not Notification.about(stance).exists?(kind: "stance_created")
  end

  test "visible blank stance is eventless and does not create subscription notification" do
    subscriber = users(:member)
    TopicReader.for(user: subscriber, topic: @poll.topic).set_volume!(:loud)
    stance = @poll.stances.undecided.find_by!(participant_id: @user.id, latest: true)
    stance.choice = @poll.poll_option_names.first

    ActionMailer::Base.deliveries.clear
    created_stance = StanceService.create(stance: stance, actor: @user)

    assert_equal stance, created_stance
    assert_not TopicItem.exists?(itemable: stance, kind: "stance_created")
    assert_not Notification.about(stance).exists?(kind: "stance_created")
    assert_not_includes ActionMailer::Base.deliveries.flat_map(&:to), subscriber.email
  end

  test "a hidden stance cannot gain deliveries when the poll later closes" do
    subscriber = users(:member)
    TopicReader.for(user: subscriber, topic: @poll.topic).set_volume!(:loud)
    @poll.update!(hide_results: :until_closed)
    stance = @poll.stances.undecided.find_by!(participant_id: @user.id, latest: true)
    stance.choice = @poll.poll_option_names.first
    stance.reason = "Hidden response"

    created_stance = StanceService.create(stance: stance, actor: @user)
    PollService.close(poll: @poll, actor: @admin)

    assert_equal stance, created_stance
    assert TopicItem.exists?(itemable: stance, kind: "stance_created", topic: @poll.topic)
    assert_not Notification.about(stance).exists?(kind: "stance_created")
  end

  test "a hidden stance reason becomes a topic item only when the poll closes" do
    @poll.update!(hide_results: :until_closed)
    stance = @poll.stances.undecided.find_by!(participant_id: @user.id, latest: true)
    stance.choice = @poll.poll_option_names.first
    stance.reason = "Reveal after close"

    StanceService.create(stance: stance, actor: @user)
    assert_not TopicItem.exists?(itemable: stance, kind: "stance_created")

    PollService.close(poll: @poll, actor: @admin)

    topic_item = TopicItem.find_by!(itemable: stance, kind: "stance_created")
    assert_equal @poll.topic_id, topic_item.topic_id
    assert_not Notification.about(stance).exists?(kind: "stance_created")
  end

  test "eventless stance creation does not depend on notification creation" do
    stance = @poll.stances.undecided.find_by!(participant_id: @user.id, latest: true)
    stance.choice = @poll.poll_option_names.first

    NotificationService.stub(:create!, ->(**) { raise "notification creation is not expected" }) do
      StanceService.create(stance: stance, actor: @user)
    end

    stance.reload
    assert_not_nil stance.cast_at
    assert_not_empty stance.stance_choices
    assert_not TopicItem.exists?(itemable: stance, kind: "stance_created")
  end

  test "an in-place stance edit does not create a notification" do
    stance = @poll.stances.undecided.find_by!(participant_id: @user.id, latest: true)
    option = @poll.poll_options.first
    stance.choice = option.name
    stance.reason = "Initial response"
    StanceService.create(stance: stance, actor: @user)

    topic_item_was_yielded = false
    updated_stance = StanceService.update(
      stance: stance,
      actor: @user,
      params: {
        reason: "Edited response",
        stance_choices_attributes: [ { poll_option_id: option.id } ]
      }
    ) { topic_item_was_yielded = true }

    assert_equal stance, updated_stance
    assert_not topic_item_was_yielded
    assert_not TopicItem.exists?(itemable: stance, kind: "stance_updated")
    assert_not Notification.about(stance).exists?(kind: "stance_updated")
  end

  test "rolls back stance creation when topic_item creation fails" do
    stance = @poll.stances.undecided.find_by!(participant_id: @user.id, latest: true)
    stance.choice = @poll.poll_option_names.first
    stance.reason = "Create a timeline item"

    assert_raises RuntimeError do
      TopicItems::StanceCreated.stub(:create!, ->(**) { raise "topic_item failed" }) do
        StanceService.create(stance: stance, actor: @user)
      end
    end

    stance.reload
    assert_nil stance.cast_at
    assert_empty stance.stance_choices
  end

  test "does not create an invalid stance" do
    invalid_stance = Stance.new(poll: @poll)

    created_stance = StanceService.create(stance: invalid_stance, actor: @user)

    assert_same invalid_stance, created_stance
    assert_predicate created_stance, :invalid?
    assert_not created_stance.persisted?
  end

  test "invalid ballot update preserves the previous vote and result counts" do
    stance = @poll.stances.undecided.find_by!(participant_id: @user.id, latest: true)
    agree = @poll.poll_options.find_by!(name: "Agree")
    StanceService.create(stance: stance.tap { |record| record.choice = "Agree" }, actor: @user)
    counts_before = @poll.reload.stance_counts
    topic_items_before = TopicItem.count

    updated_stance = StanceService.update(
      stance: stance,
      actor: @user,
      params: { stance_choices_attributes: [{ poll_option_id: agree.id, score: -1 }] }
    )

    assert_same stance, updated_stance
    assert_predicate updated_stance, :invalid?
    assert_equal({ agree.id.to_s => 1 }, stance.reload.option_scores)
    assert_equal counts_before, @poll.reload.stance_counts
    assert_equal topic_items_before, TopicItem.count
  end

  test "does not allow an unauthorized member to create a stance" do
    agree = @poll.poll_options.find_by(name: 'Agree')
    new_stance = Stance.new(poll: @poll, reason: 'trying to vote')
    new_stance.stance_choices_attributes = [{ poll_option_id: agree.id }]

    assert_raises CanCan::AccessDenied do
      StanceService.create(stance: new_stance, actor: @alien)
    end
  end

  test "sets topic_item parent to the poll created topic_item" do
    poll_created_topic_item = @poll.created_topic_item

    stance = @poll.stances.undecided.find_by!(participant_id: @user.id, latest: true)
    stance.choice = @poll.poll_option_names.first
    stance.reason = "hello"
    topic_item = nil
    StanceService.create(stance: stance, actor: @user) { |created_topic_item| topic_item = created_topic_item }

    assert_equal poll_created_topic_item.id, topic_item.parent.id
  end

  test "updates total_score on the poll" do
    stance = @poll.stances.undecided.find_by!(participant_id: @user.id, latest: true)
    stance.choice = 'Agree'
    StanceService.create(stance: stance, actor: @user)

    assert @poll.reload.total_score >= 1
  end

  test "redacts a stance reason" do
    stance = @poll.stances.undecided.find_by!(participant_id: @user.id, latest: true)
    stance.choice = 'Agree'
    stance.reason = "This should be hidden"
    StanceService.create(stance: stance, actor: @user)

    StanceService.redact(stance: stance, actor: @admin)

    assert_not_nil stance.reload.redacted_at
    assert_equal @admin.id, stance.redactor_id
    assert_equal "This should be hidden", stance.reason
    assert_nil PgSearch::Document.find_by(searchable_type: 'Stance', searchable_id: stance.id)
  end

  test "does not allow a non-admin to redact a stance reason" do
    stance = @poll.stances.undecided.find_by!(participant_id: @user.id, latest: true)
    stance.choice = 'Agree'
    stance.reason = "This should be hidden"
    StanceService.create(stance: stance, actor: @user)

    assert_raises CanCan::AccessDenied do
      StanceService.redact(stance: stance, actor: @user)
    end

    assert_nil stance.reload.redacted_at
  end

  test "unredacts a stance reason" do
    stance = @poll.stances.undecided.find_by!(participant_id: @user.id, latest: true)
    stance.choice = 'Agree'
    stance.reason = "This was hidden"
    StanceService.create(stance: stance, actor: @user)
    StanceService.redact(stance: stance, actor: @admin)
    assert_not_nil stance.reload.redacted_at

    StanceService.unredact(stance: stance, actor: @admin)
    assert_nil stance.reload.redacted_at
    assert_nil stance.redactor_id
    assert PgSearch::Document.exists?(searchable_type: 'Stance', searchable_id: stance.id)
  end

  test "does not allow a non-admin to unredact a stance reason" do
    stance = @poll.stances.undecided.find_by!(participant_id: @user.id, latest: true)
    stance.choice = 'Agree'
    stance.reason = "This was hidden"
    StanceService.create(stance: stance, actor: @user)
    StanceService.redact(stance: stance, actor: @admin)

    assert_raises CanCan::AccessDenied do
      StanceService.unredact(stance: stance, actor: @user)
    end

    assert_not_nil stance.reload.redacted_at
  end

  test "update cannot move a stance to another poll" do
    stance = @poll.stances.undecided.find_by!(participant_id: @user.id, latest: true)
    stance.choice = 'Agree'
    StanceService.create(stance: stance, actor: @user)

    target_poll = PollService.create(params: {
      title: 'Target Poll',
      poll_type: 'proposal',
      closing_at: 3.days.from_now,
      group_id: @group.id,
      poll_option_names: ['Agree', 'Disagree']
    }, actor: @admin)

    StanceService.update(
      stance: stance,
      actor: @user,
      params: {
        poll_id: target_poll.id,
        reason: 'Still in the original poll',
        stance_choices_attributes: [{ poll_option_id: @poll.poll_options.find_by!(name: 'Agree').id }]
      }
    )

    assert_equal @poll.id, stance.reload.poll_id
    assert_equal 'Still in the original poll', stance.reason

    stance.poll = target_poll
    error = assert_raises(RuntimeError) { stance.save! }
    assert_equal "Stance poll_id cannot change", error.message
    assert_equal @poll.id, stance.reload.poll_id
  end

  # -- Redeem --

  test "redeems a guest stance for a verified user" do
    guest = User.create!(name: 'GuestUser', email: "guest#{SecureRandom.hex(4)}@example.com",
                         email_verified: false, username: "guest#{SecureRandom.hex(4)}")
    # Don't add @admin to group again - they're already a member, which auto-creates a stance.
    # Use a fresh verified user not in the group to avoid that.
    voter = User.create!(name: 'RedeemVoter', email: "redeem#{SecureRandom.hex(4)}@example.com",
                         email_verified: true, username: "redeem#{SecureRandom.hex(4)}")

    guest_stance = @poll.stances.create!(
      participant_id: guest.id,
      reason: "Old one",
      inviter: @admin,
      latest: true
    )

    assert_equal false, guest.email_verified
    StanceService.redeem(stance: guest_stance, actor: voter)
    assert_equal voter, guest_stance.reload.participant
  end

  test "does not redeem stance for another verified user" do
    other_stance = @poll.stances.find_by(participant_id: @user.id)
    other_stance.update!(inviter: @admin)

    voter = User.create!(name: 'RedeemVoter2', email: "redeem2#{SecureRandom.hex(4)}@example.com",
                         email_verified: true, username: "redeem2#{SecureRandom.hex(4)}")

    StanceService.redeem(stance: other_stance, actor: voter)
    assert_equal @user, other_stance.reload.participant
  end
end
