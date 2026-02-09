require 'test_helper'

class StanceServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:discussion_author)
    @another_user = users(:another_user)
    @group = groups(:test_group)
    @discussion = discussions(:test_discussion)

    @poll = Poll.new(
      title: 'Test Poll',
      author: @user,
      poll_type: 'proposal',
      closing_at: 3.days.from_now,
      discussion: @discussion,
      poll_option_names: ['Agree', 'Disagree']
    )
    PollService.create(poll: @poll, actor: @user)
    @poll.reload
  end

  # -- Create --

  test "creates a new stance" do
    voter = User.create!(name: 'StanceVoter', email: "stancevoter#{SecureRandom.hex(4)}@example.com",
                         email_verified: true, username: "stancevoter#{SecureRandom.hex(4)}")
    @group.add_member!(voter)

    stance = @poll.stances.find_by(participant_id: voter.id)
    stance.choice = @poll.poll_option_names.first
    stance.reason = "I agree"

    event = StanceService.create(stance: stance, actor: voter)
    assert_kind_of Event, event
  end

  test "does not create an invalid stance" do
    proposal = Poll.new(
      title: 'Proposal',
      author: @user,
      poll_type: 'proposal',
      closing_at: 3.days.from_now,
      discussion: @discussion,
      poll_option_names: ['Agree', 'Abstain', 'Disagree', 'Block']
    )
    PollService.create(poll: proposal, actor: @user)

    invalid_stance = Stance.new(poll: proposal)

    assert_raises ActiveRecord::RecordInvalid do
      StanceService.create(stance: invalid_stance, actor: @user)
    end
  end

  test "does not allow an unauthorized member to create a stance" do
    unauthorized_user = User.create!(
      name: 'Unauthorized',
      email: "unauthorizedstance#{SecureRandom.hex(4)}@example.com",
      email_verified: true,
      username: "unauthorizedstance#{SecureRandom.hex(4)}"
    )

    agree = @poll.poll_options.find_by(name: 'Agree')
    new_stance = Stance.new(poll: @poll, reason: 'trying to vote')
    new_stance.stance_choices_attributes = [{ poll_option_id: agree.id }]

    assert_raises CanCan::AccessDenied do
      StanceService.create(stance: new_stance, actor: unauthorized_user)
    end
  end

  test "sets event parent to the poll created event" do
    voter = User.create!(name: 'EventParentVoter', email: "eventparent#{SecureRandom.hex(4)}@example.com",
                         email_verified: true, username: "eventparent#{SecureRandom.hex(4)}")
    @group.add_member!(voter)

    poll_created_event = @poll.created_event

    stance = @poll.stances.find_by(participant_id: voter.id, latest: true)
    stance.choice = @poll.poll_option_names.first
    stance.reason = "hello"
    event = StanceService.create(stance: stance, actor: voter)

    assert_equal poll_created_event.id, event.parent.id
  end

  test "updates total_score on the poll" do
    voter = User.create!(name: 'ScoreVoter', email: "scorevoter#{SecureRandom.hex(4)}@example.com",
                         email_verified: true, username: "scorevoter#{SecureRandom.hex(4)}")
    @group.add_member!(voter)

    stance = @poll.stances.find_by(participant_id: voter.id, latest: true)
    stance.choice = 'Agree'
    StanceService.create(stance: stance, actor: voter)

    assert @poll.reload.total_score >= 1
  end

  # -- Redeem --

  test "redeems a guest stance for a verified user" do
    guest = User.create!(name: 'GuestUser', email: "guest#{SecureRandom.hex(4)}@example.com",
                         email_verified: false, username: "guest#{SecureRandom.hex(4)}")
    voter = User.create!(name: 'RedeemVoter', email: "redeem#{SecureRandom.hex(4)}@example.com",
                         email_verified: true, username: "redeem#{SecureRandom.hex(4)}")
    # Don't add voter to group - add_member! triggers PollService.group_members_added
    # which auto-creates a stance, causing StanceService.redeem to return early.

    guest_stance = @poll.stances.create!(
      participant_id: guest.id,
      guest: true,
      reason: "Old one",
      inviter: @user,
      latest: true
    )

    assert_equal false, guest.email_verified
    StanceService.redeem(stance: guest_stance, actor: voter)
    assert_equal voter, guest_stance.reload.participant
  end

  test "does not redeem stance for another verified user" do
    other_member = User.create!(name: 'OtherMember', email: "othermember#{SecureRandom.hex(4)}@example.com",
                                email_verified: true, username: "othermember#{SecureRandom.hex(4)}")
    @group.add_member!(other_member)

    voter = User.create!(name: 'RedeemVoter2', email: "redeem2#{SecureRandom.hex(4)}@example.com",
                         email_verified: true, username: "redeem2#{SecureRandom.hex(4)}")

    other_stance = @poll.stances.find_by(participant_id: other_member.id)
    other_stance.update!(inviter: @user)

    StanceService.redeem(stance: other_stance, actor: voter)
    assert_equal other_member, other_stance.reload.participant
  end
end
