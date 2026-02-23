require 'test_helper'

class PollTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @group = groups(:group)
  end

  def poll_params(**overrides)
    {
      poll_type: "poll",
      title: "Test poll",
      details: "with a description",
      poll_option_names: ["engage"],
      closing_at: 5.days.from_now,
      notify_on_closing_soon: "voters",
      notify_on_open: false
    }.merge(overrides)
  end

  def create_poll(**overrides)
    PollService.create(params: poll_params(**overrides), actor: @admin)
  end

  def create_ranked_choice(**overrides)
    PollService.create(params: poll_params(
      poll_type: "ranked_choice",
      title: "Ranked choice",
      poll_option_names: %w[apple banana orange],
      custom_fields: { minimum_stance_choices: 2 },
      **overrides
    ), actor: @admin)
  end

  def create_meeting(**overrides)
    PollService.create(params: poll_params(
      poll_type: "meeting",
      title: "Test meeting",
      poll_option_names: ['01-01-2015'],
      custom_fields: { can_respond_maybe: false },
      **overrides
    ), actor: @admin)
  end

  test "validates correctly if no poll option changes have been made" do
    poll = create_poll(poll_option_names: ["agree"])
    assert poll.valid?
  end

  test "does not allow changing poll options if the template does not allow" do
    poll = create_poll(poll_option_names: ["agree"])
    poll.poll_options.build
    refute poll.valid?
  end

  test "does not allow higher minimum stance choices than number of poll options" do
    ranked_choice = create_ranked_choice
    ranked_choice.minimum_stance_choices = ranked_choice.poll_options.length + 1
    ranked_choice.valid?
    assert_equal ranked_choice.poll_options.length, ranked_choice.minimum_stance_choices
  end

  test "allows closing dates in the future" do
    poll = Poll.new(
      poll_type: "poll",
      title: "Test poll",
      author: @admin,
      poll_option_names: ["agree"],
      closing_at: 1.day.from_now
    )
    assert poll.valid?
  end

  test "disallows closing dates in the past" do
    poll = Poll.new(
      poll_type: "poll",
      title: "Test poll",
      author: @admin,
      poll_option_names: ["agree"],
      closing_at: 1.day.ago
    )
    refute poll.valid?
  end

  test "allows past closing dates if it is closed" do
    poll = Poll.new(
      poll_type: "poll",
      title: "Test poll",
      author: @admin,
      poll_option_names: ["agree"],
      closed_at: 1.day.ago,
      closing_at: 1.day.ago
    )
    assert poll.valid?
  end

  test "assigns poll options" do
    option_poll = create_poll(poll_option_names: ['A', 'C', 'B'])
    assert_equal ['A', 'C', 'B'], option_poll.poll_options.map(&:name)
  end

  test "orders by priority when non-meeting poll" do
    poll = create_poll
    poll.update(poll_option_names: ['Orange', 'Apple'])
    assert_equal 'Orange', poll.poll_options.first.name
    assert_equal 'Apple', poll.poll_options.second.name
    assert_equal ['Orange', 'Apple'], poll.poll_option_names
  end

  test "orders by name when meeting poll" do
    meeting = create_meeting
    meeting.update(poll_option_names: ['01-01-2018', '01-01-2017', '01-01-2016'])
    assert_equal '01-01-2016', meeting.poll_options.first.name
    assert_equal '01-01-2017', meeting.poll_options.second.name
    assert_equal '01-01-2018', meeting.poll_options.third.name
    assert_equal ['01-01-2016', '01-01-2017', '01-01-2018'], meeting.reload.poll_option_names
  end

  test "members includes guests" do
    poll = create_poll(group_id: @group.id)
    hex = SecureRandom.hex(4)
    guest = User.create!(name: "Guest", email: "guest_#{hex}@example.com", username: "guest#{hex}")
    assert_difference -> { poll.members.count }, 1 do
      poll.stances.create!(participant_id: guest.id, inviter: @admin)
      poll.add_guest!(guest, @admin)
    end
  end

  test "members includes members of the formal group" do
    poll = create_poll(group_id: @group.id)
    hex = SecureRandom.hex(4)
    new_member = User.create!(name: "New Member", email: "newmember#{hex}@example.com", username: "newmember#{hex}")
    assert_difference -> { poll.members.count }, 1 do
      @group.add_member!(new_member)
    end
  end

  test "increments voters" do
    poll = create_poll(group_id: @group.id, specified_voters_only: true)
    voter = users(:alien)
    assert_difference -> { poll.voters.count }, 1 do
      Stance.create!(poll: poll, participant: voter)
    end
  end

  test "does not increment decided_voters without a choice" do
    poll = create_poll(group_id: @group.id, specified_voters_only: true)
    voter = users(:alien)
    assert_no_difference -> { poll.decided_voters.count } do
      Stance.create!(poll: poll, participant: voter)
    end
  end

  test "increments undecided_voters without a choice" do
    poll = create_poll(group_id: @group.id, specified_voters_only: true)
    voter = users(:alien)
    assert_difference -> { poll.undecided_voters.count }, 1 do
      Stance.create!(poll: poll, participant: voter)
    end
  end

  test "cast vote increments voters" do
    poll = create_poll(group_id: @group.id, specified_voters_only: true)
    voter = users(:alien)
    assert_difference -> { poll.voters.count }, 1 do
      Stance.create!(poll: poll, choice: poll.poll_option_names.first, participant: voter)
    end
  end

  test "cast vote increments decided_voters" do
    poll = create_poll(group_id: @group.id, specified_voters_only: true)
    voter = users(:alien)
    assert_difference -> { poll.decided_voters.count }, 1 do
      Stance.create!(poll: poll, choice: poll.poll_option_names.first, participant: voter)
    end
  end

  test "cast vote does not increment undecided voters" do
    poll = create_poll(group_id: @group.id, specified_voters_only: true)
    voter = users(:alien)
    assert_no_difference -> { poll.undecided_voters.count } do
      Stance.create!(poll: poll, choice: poll.poll_option_names.first, participant: voter)
    end
  end

  test "defaults to the authors time zone" do
    hex = SecureRandom.hex(4)
    author = User.create!(name: "Seoul User", email: "seoul#{hex}@example.com", username: "seoul#{hex}", time_zone: "Asia/Seoul")
    @group.add_member!(author)
    poll = PollService.create(params: poll_params(group_id: @group.id), actor: author)
    assert_equal "Asia/Seoul", poll.time_zone
  end
end
