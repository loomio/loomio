require 'test_helper'

class StanceServiceTest < ActiveSupport::TestCase
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

    event = StanceService.create(stance: stance, actor: @user)
    assert_kind_of Event, event
    assert reader.reload.has_read?(event.sequence_id)
    assert_equal 0, reader.unread_items_count
  end

  test "rolls back stance creation when event creation fails" do
    stance = @poll.stances.undecided.find_by!(participant_id: @user.id, latest: true)
    stance.choice = @poll.poll_option_names.first

    assert_raises RuntimeError do
      Events::StanceCreated.stub(:publish!, ->(*) { raise "event failed" }) do
        StanceService.create(stance: stance, actor: @user)
      end
    end

    stance.reload
    assert_nil stance.cast_at
    assert_empty stance.stance_choices
  end

  test "does not create an invalid stance" do
    invalid_stance = Stance.new(poll: @poll)

    assert_raises ActiveRecord::RecordInvalid do
      StanceService.create(stance: invalid_stance, actor: @user)
    end
  end

  test "invalid ballot update preserves the previous vote and result counts" do
    stance = @poll.stances.undecided.find_by!(participant_id: @user.id, latest: true)
    agree = @poll.poll_options.find_by!(name: "Agree")
    StanceService.create(stance: stance.tap { |record| record.choice = "Agree" }, actor: @user)
    counts_before = @poll.reload.stance_counts
    events_before = Event.count

    assert_raises ActiveRecord::RecordInvalid do
      StanceService.update(
        stance: stance,
        actor: @user,
        params: { stance_choices_attributes: [{ poll_option_id: agree.id, score: -1 }] }
      )
    end

    assert_equal({ agree.id.to_s => 1 }, stance.reload.option_scores)
    assert_equal counts_before, @poll.reload.stance_counts
    assert_equal events_before, Event.count
  end

  test "does not allow an unauthorized member to create a stance" do
    agree = @poll.poll_options.find_by(name: 'Agree')
    new_stance = Stance.new(poll: @poll, reason: 'trying to vote')
    new_stance.stance_choices_attributes = [{ poll_option_id: agree.id }]

    assert_raises CanCan::AccessDenied do
      StanceService.create(stance: new_stance, actor: @alien)
    end
  end

  test "sets event parent to the poll created event" do
    poll_created_event = @poll.created_event

    stance = @poll.stances.undecided.find_by!(participant_id: @user.id, latest: true)
    stance.choice = @poll.poll_option_names.first
    stance.reason = "hello"
    event = StanceService.create(stance: stance, actor: @user)

    assert_equal poll_created_event.id, event.parent.id
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
