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

  test "destroying a poll's topic destroys the poll (no orphaned topic_id)" do
    poll = create_poll
    topic = poll.topic
    assert_equal poll, topic.topicable

    topic.destroy

    refute Poll.exists?(poll.id), "poll should be destroyed with its topic, not orphaned"
  end

  test "destroying a group destroys its standalone polls" do
    poll = create_poll(group_id: @group.id)
    poll_id = poll.id

    @group.destroy

    refute Poll.exists?(poll_id), "group destroy should cascade to topic then poll"
  end

  test "database rejects a poll referencing a non-existent topic" do
    poll = create_poll
    poll.update_column(:topic_id, 0)
    # FK is deferrable/initially-deferred, so it fires at commit; force the
    # check now to assert it is enforced.
    assert_raises(ActiveRecord::InvalidForeignKey) do
      ActiveRecord::Base.connection.execute("SET CONSTRAINTS ALL IMMEDIATE")
    end
  end

  test "database rejects anonymous stance voting" do
    poll = create_poll

    assert_raises(ActiveRecord::StatementInvalid) do
      poll.update_columns(anonymous: true, voting_system: Poll.voting_systems.fetch("stance"))
    end
  end

  test "database rejects identified anonymous-ballot voting" do
    poll = create_poll

    assert_raises(ActiveRecord::StatementInvalid) do
      poll.update_columns(anonymous: false, voting_system: Poll.voting_systems.fetch("anonymous_ballot"))
    end
  end

  test "validates correctly if no poll option changes have been made" do
    poll = create_poll(poll_option_names: ["agree"])
    assert poll.valid?
  end

  test "every poll type declares a complete ballot policy without validation switches" do
    expected_rules = {
      "count" => "bounded",
      "check" => "bounded",
      "question" => "reason_only",
      "proposal" => "bounded",
      "meeting" => "bounded",
      "poll" => "bounded",
      "dot_vote" => "dot_vote",
      "score" => "bounded",
      "ranked_choice" => "ranked_points",
      "stv" => "ranked_preferences"
    }

    assert_equal expected_rules, AppConfig.poll_types.transform_values { |config| config["ballot_rule"] }
    AppConfig.poll_types.each_value do |config|
      assert_empty config.keys.grep(/^validate_/)
    end
  end

  test "score bounds must be nonnegative and ordered" do
    assert_raises(ActiveRecord::RecordInvalid) do
      create_poll(poll_type: "score", poll_option_names: %w[apple orange], min_score: -1)
    end

    poll = create_poll(poll_type: "score", poll_option_names: %w[apple orange])

    poll.min_score = -1
    refute poll.valid?
    assert poll.errors.added?(:min_score, :invalid)

    poll.min_score = 5
    poll.max_score = 4
    refute poll.valid?
    assert poll.errors.added?(:max_score, :invalid)
  end

  test "a legacy negative-score poll can be discarded" do
    poll = create_poll(poll_type: "score", poll_option_names: %w[apple orange])
    poll.update_column(:min_score, -1)

    PollService.discard(poll: poll, actor: @admin)

    assert poll.reload.discarded?
  end

  test "an existing negative scale does not validate again for unrelated edits" do
    poll = create_poll(poll_type: "score", poll_option_names: %w[apple orange])
    poll.update_columns(min_score: -1, closed_at: Time.current)

    assert poll.update(title: "Edited historical score poll")
    assert_equal(-1, poll.reload.min_score)
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

  test "ballot configuration ignores JSON custom fields" do
    poll = create_poll(poll_type: "dot_vote", poll_option_names: %w[apple banana orange])
    poll.update_columns(
      min_score: nil,
      max_score: nil,
      dots_per_person: nil,
      minimum_stance_choices: nil,
      maximum_stance_choices: nil,
      custom_fields: poll.custom_fields.merge(
        "min_score" => 3,
        "max_score" => 3,
        "dots_per_person" => 1,
        "minimum_stance_choices" => 2,
        "maximum_stance_choices" => 2
      )
    )

    poll.reload
    assert_equal 0, poll.min_score
    assert_nil poll.max_score
    assert_equal 8, poll.dots_per_person
    assert_equal 0, poll.minimum_stance_choices
    assert_equal 3, poll.maximum_stance_choices

    poll.update!(min_score: 2)
    assert_equal 3, poll.reload.custom_fields["min_score"]
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

  test "until vote results are available to the backend before voting" do
    poll = create_poll(hide_results: "until_vote")

    assert poll.show_results?(voted: false)
    assert poll.show_results?(voted: true)
  end

  test "until closed results remain hidden from the backend until close" do
    poll = create_poll(hide_results: "until_closed")

    refute poll.show_results?(voted: false)
    refute poll.show_results?(voted: true)
    poll.update!(closed_at: Time.current)
    assert poll.show_results?(voted: false)
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
