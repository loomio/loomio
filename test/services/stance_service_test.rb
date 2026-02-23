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
    stance = @poll.stances.undecided.find_by!(participant_id: @user.id, latest: true)
    stance.choice = @poll.poll_option_names.first
    stance.reason = "I agree"

    event = StanceService.create(stance: stance, actor: @user)
    assert_kind_of Event, event
  end

  test "does not create an invalid stance" do
    invalid_stance = Stance.new(poll: @poll)

    assert_raises ActiveRecord::RecordInvalid do
      StanceService.create(stance: invalid_stance, actor: @user)
    end
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
