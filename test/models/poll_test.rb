require 'test_helper'

class PollTest < ActiveSupport::TestCase
  setup do
    @user = users(:normal_user)
    @group = groups(:test_group)
    @group.add_admin!(@user)
  end

  def create_poll(**attrs)
    defaults = {
      poll_type: "poll",
      title: "Test poll",
      details: "with a description",
      author: @user,
      poll_option_names: ["engage"],
      closing_at: 5.days.from_now,
      opened_at: Time.now,
      notify_on_closing_soon: "voters"
    }
    poll = Poll.new(defaults.merge(attrs))
    poll.save!
    poll.create_missing_created_event!
    poll
  end

  def create_ranked_choice(**attrs)
    defaults = {
      poll_type: "ranked_choice",
      title: "Ranked choice",
      details: "with a description",
      author: @user,
      poll_option_names: %w[apple banana orange],
      custom_fields: { minimum_stance_choices: 2 },
      closing_at: 5.days.from_now,
      opened_at: Time.now,
      notify_on_closing_soon: "voters"
    }
    poll = Poll.new(defaults.merge(attrs))
    poll.save!
    poll.create_missing_created_event!
    poll
  end

  def create_meeting(**attrs)
    defaults = {
      poll_type: "meeting",
      title: "Test meeting",
      details: "with a description",
      author: @user,
      poll_option_names: ['01-01-2015'],
      custom_fields: { can_respond_maybe: false },
      closing_at: 5.days.from_now,
      opened_at: Time.now,
      notify_on_closing_soon: "voters"
    }
    poll = Poll.new(defaults.merge(attrs))
    poll.save!
    poll.create_missing_created_event!
    poll
  end

  test "validates correctly if no poll option changes have been made" do
    poll = Poll.new(
      poll_type: "poll",
      title: "Test poll",
      author: @user,
      poll_option_names: ["agree"],
      closing_at: 5.days.from_now
    )
    poll.save!
    assert poll.valid?
  end

  test "does not allow changing poll options if the template does not allow" do
    poll = Poll.new(
      poll_type: "poll",
      title: "Test poll",
      author: @user,
      poll_option_names: ["agree"],
      closing_at: 5.days.from_now
    )
    poll.save!
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
      author: @user,
      poll_option_names: ["agree"],
      closing_at: 1.day.from_now
    )
    assert poll.valid?
  end

  test "disallows closing dates in the past" do
    poll = Poll.new(
      poll_type: "poll",
      title: "Test poll",
      author: @user,
      poll_option_names: ["agree"],
      closing_at: 1.day.ago
    )
    refute poll.valid?
  end

  test "allows past closing dates if it is closed" do
    poll = Poll.new(
      poll_type: "poll",
      title: "Test poll",
      author: @user,
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
    poll = create_poll(group: @group)
    hex = SecureRandom.hex(4)
    guest = User.create!(name: "Guest", email: "guest_#{hex}@example.com", username: "guest#{hex}")
    assert_difference -> { poll.members.count }, 1 do
      poll.stances.create!(participant_id: guest.id, inviter: @user)
      poll.add_guest!(guest, @user)
    end
  end

  test "members includes members of the formal group" do
    poll = create_poll(group: @group)
    hex = SecureRandom.hex(4)
    new_member = User.create!(name: "New Member", email: "newmember#{hex}@example.com", username: "newmember#{hex}")
    assert_difference -> { poll.members.count }, 1 do
      @group.add_member!(new_member)
    end
  end

  test "increments voters" do
    poll = create_poll(group: @group, specified_voters_only: true)
    voter = users(:another_user)
    assert_difference -> { poll.voters.count }, 1 do
      Stance.create!(poll: poll, participant: voter)
    end
  end

  test "does not increment decided_voters without a choice" do
    poll = create_poll(group: @group, specified_voters_only: true)
    voter = users(:another_user)
    assert_no_difference -> { poll.decided_voters.count } do
      Stance.create!(poll: poll, participant: voter)
    end
  end

  test "increments undecided_voters without a choice" do
    poll = create_poll(group: @group, specified_voters_only: true)
    voter = users(:another_user)
    assert_difference -> { poll.undecided_voters.count }, 1 do
      Stance.create!(poll: poll, participant: voter)
    end
  end

  test "cast vote increments voters" do
    poll = create_poll(group: @group, specified_voters_only: true)
    voter = users(:another_user)
    assert_difference -> { poll.voters.count }, 1 do
      Stance.create!(poll: poll, choice: poll.poll_option_names.first, participant: voter)
    end
  end

  test "cast vote increments decided_voters" do
    poll = create_poll(group: @group, specified_voters_only: true)
    voter = users(:another_user)
    assert_difference -> { poll.decided_voters.count }, 1 do
      Stance.create!(poll: poll, choice: poll.poll_option_names.first, participant: voter)
    end
  end

  test "cast vote does not increment undecided voters" do
    poll = create_poll(group: @group, specified_voters_only: true)
    voter = users(:another_user)
    assert_no_difference -> { poll.undecided_voters.count } do
      Stance.create!(poll: poll, choice: poll.poll_option_names.first, participant: voter)
    end
  end

  test "defaults to the authors time zone" do
    hex = SecureRandom.hex(4)
    author = User.create!(name: "Seoul User", email: "seoul#{hex}@example.com", username: "seoul#{hex}", time_zone: "Asia/Seoul")
    @group.add_member!(author)
    poll = create_poll(author: author, group: @group)
    assert_equal "Asia/Seoul", poll.time_zone
  end
end
