require 'test_helper'

class PollPreopeningSettingsTest < ActiveSupport::TestCase
  setup do
    @admin = users(:admin)
    @voters = [users(:member_normal), users(:guest_normal)]
    topics(:discussion_topic).update!(allow_concurrent_polls: true)
  end

  test "switching voting mode before opening preserves the electorate for group and direct polls" do
    %i[discussion_topic direct_topic].each do |topic_name|
      actor = topic_name == :direct_topic ? users(:guest_admin_normal) : @admin
      voters = topic_name == :direct_topic ? [actor, users(:guest_normal)] : @voters
      poll = create_poll(topic: topics(topic_name), actor: actor, voters: voters)
      invitations = poll.stances.latest.pluck(:participant_id, :inviter_id, :created_at).sort
      options = poll.poll_options.pluck(:id)

      PollService.update(poll: poll, actor: actor, params: {anonymous: true})

      assert_empty poll.errors
      assert poll.reload.anonymous?
      assert_not poll.opened?
      assert_equal 'until_closed', poll.hide_results
      assert_equal 'disabled', poll.stance_reason_required
      assert_equal 'voters_uncast', poll.notify_on_closing_soon
      assert_empty poll.stances
      assert_equal invitations, poll.anonymous_poll_voters.pluck(:voter_id, :inviter_id, :invited_at).sort
      assert_equal voters.map(&:id).sort, poll.anonymous_poll_voters.pluck(:voter_id).sort
      assert_equal options, poll.poll_options.pluck(:id)
      assert_equal voters.size, poll.vote_count_eligible
      assert_equal 0, poll.vote_count_cast

      PollService.update(poll: poll, actor: actor, params: {
        anonymous: false, hide_results: 'off', stance_reason_required: 'optional'
      })

      assert_empty poll.errors
      assert_not poll.reload.anonymous?
      assert_equal 'off', poll.hide_results
      assert_empty poll.anonymous_poll_voters
      assert_equal invitations, poll.stances.latest.pluck(:participant_id, :inviter_id, :created_at).sort
      assert_equal options, poll.poll_options.pluck(:id)
      assert_equal voters.size, poll.vote_count_eligible
    end
  end

  test "a named poll converted before opening can accept anonymous ballots once opened" do
    poll = create_poll
    PollService.update(poll: poll, actor: @admin, params: {anonymous: true, opening_at: nil})
    assert_empty poll.errors
    assert poll.reload.opened?

    ballot = AnonymousBallot.new(poll: poll, anonymous_ballot_choices_attributes: [
      {poll_option_id: poll.poll_options.first.id, score: 1}
    ])
    AnonymousBallotService.create(anonymous_ballot: ballot, actor: @voters.first)

    assert ballot.persisted?
    assert poll.anonymous_poll_voters.find_by!(voter: @voters.first).ballot_submitted?
    assert_empty poll.stances
    assert_equal 1, poll.anonymous_ballots.count
  end

  test "an anonymous poll converted before opening can accept named votes once opened" do
    poll = create_poll(anonymous: true)
    PollService.update(poll: poll, actor: @admin, params: {
      anonymous: false, hide_results: 'off', stance_reason_required: 'optional', opening_at: nil
    })
    assert_empty poll.errors
    assert poll.reload.opened?
    stance = poll.stances.latest.find_by!(participant: @voters.first)
    stance.choice = 'Yes'
    StanceService.create(stance: stance, actor: @voters.first)

    assert stance.reload.cast_at
    assert_equal 1, poll.reload.vote_count_cast
    assert_empty poll.anonymous_ballots
    assert_empty poll.anonymous_poll_voters
  end

  test "a failed electorate conversion rolls back the whole edit" do
    poll = create_poll
    stance_ids = poll.stances.pluck(:id)
    assert_raises RuntimeError do
      AnonymousPollVoter.stub(:insert_all!, ->(*) { raise 'conversion failed' }) do
        PollService.update(poll: poll, actor: @admin, params: {anonymous: true, title: 'Changed title'})
      end
    end
    assert_not poll.reload.anonymous?
    assert_equal 'Scheduled decision', poll.title
    assert_equal stance_ids, poll.stances.pluck(:id)
    assert_empty poll.anonymous_poll_voters
  end

  test "conversion guards reject unsafe storage before changing electorate or vote records" do
    {
      opened: 'after voting has opened', cast: 'with cast stances', choices: 'with stance choices',
      ballots: 'with anonymous ballots', submitted: 'with submitted anonymous voters',
      anonymous_destination: 'into an existing anonymous electorate', named_destination: 'into existing active named stances'
    }.each do |state, message|
      anonymous = %i[ballots submitted named_destination].include?(state)
      poll = create_poll(anonymous: anonymous)
      case state
      when :opened
        poll.update_columns(opened_at: Time.current)
      when :cast
        poll.stances.first.update_columns(cast_at: Time.current)
      when :choices
        StanceChoice.create!(stance: poll.stances.first, poll_option: poll.poll_options.first, score: 1)
      when :ballots
        AnonymousBallot.insert_all!([{id: SecureRandom.uuid, poll_id: poll.id, none_of_the_above: false}])
      when :submitted
        poll.anonymous_poll_voters.first.update_columns(ballot_submitted: true)
      when :anonymous_destination
        AnonymousPollVoter.insert_all!([{poll_id: poll.id, voter_id: @voters.first.id}])
      when :named_destination
        Stance.insert_all!([{poll_id: poll.id, participant_id: @voters.first.id, inviter_id: @admin.id, token: SecureRandom.alphanumeric(24)}])
      end
      snapshot = electorate_and_votes(poll)
      poll.anonymous = !anonymous

      error = assert_raises(RuntimeError) { poll.send(:convert_unopened_electorate) }

      assert_includes error.message, message
      assert_equal snapshot, electorate_and_votes(poll), state.to_s
      assert_equal anonymous, poll.reload.anonymous?
    end
  end

  test "a stale pre-opening form cannot change anonymity once voting has opened" do
    [false, true].each do |anonymous|
      poll = create_poll(anonymous: anonymous)
      stale = Poll.find(poll.id)
      PollService.update(poll: poll, actor: @admin, params: {opening_at: nil})
      assert poll.reload.opened?

      PollService.update(poll: stale, actor: @admin, params: {anonymous: !anonymous})

      assert stale.errors[:anonymous].any?
      assert_equal anonymous, poll.reload.anonymous?
      assert_equal @voters.size, anonymous ? poll.anonymous_poll_voters.count : poll.stances.latest.count
    end
  end

  test "poll type can change before opening and stays fixed once opened" do
    poll = create_poll
    PollService.update(poll: poll, actor: @admin, params: {poll_type: 'ranked_choice', choice_count_min: 2})
    assert_empty poll.errors
    assert_equal 'ranked_choice', poll.reload.poll_type

    PollService.update(poll: poll, actor: @admin, params: {opening_at: nil})
    PollService.update(poll: poll, actor: @admin, params: {poll_type: 'poll'})
    assert poll.errors.added?(:poll_type, :invalid)
    assert_equal 'ranked_choice', poll.reload.poll_type
  end

  test "anonymous ballots cannot be converted even on a row missing its opening timestamp" do
    poll = create_poll(anonymous: true)
    PollService.update(poll: poll, actor: @admin, params: {opening_at: nil})
    ballot = AnonymousBallot.new(poll: poll, anonymous_ballot_choices_attributes: [
      {poll_option_id: poll.poll_options.first.id, score: 1}
    ])
    AnonymousBallotService.create(anonymous_ballot: ballot, actor: @voters.first)
    poll.update_columns(opened_at: nil)

    PollService.update(poll: poll, actor: @admin, params: {anonymous: false, hide_results: 'off'})

    assert poll.errors[:anonymous].any?
    assert poll.reload.anonymous?
    assert_equal [ballot.id], poll.anonymous_ballots.pluck(:id)
    assert poll.anonymous_poll_voters.find_by!(voter: @voters.first).ballot_submitted?
  end

  test "named votes cannot be converted even on a row missing its opening timestamp" do
    poll = create_poll
    PollService.update(poll: poll, actor: @admin, params: {opening_at: nil})
    stance = poll.stances.latest.find_by!(participant: @voters.first)
    stance.choice = 'Yes'
    StanceService.create(stance: stance, actor: @voters.first)
    poll.update_columns(opened_at: nil)

    PollService.update(poll: poll, actor: @admin, params: {anonymous: true})

    assert poll.errors[:anonymous].any?
    assert_not poll.reload.anonymous?
    assert stance.reload.cast_at
    assert_equal ['Yes'], stance.poll_options.pluck(:name)
    assert_empty poll.anonymous_poll_voters
  end

  test "switching mode restores current membership weights when named weighted voting is chosen" do
    groups(:group).membership_for(@voters.first).update!(weight: 3)
    poll = create_poll
    PollService.update(poll: poll, actor: @admin, params: {weighted_voting: true})
    assert_equal BigDecimal('3'), poll.stances.latest.find_by!(participant: @voters.first).weight

    PollService.update(poll: poll, actor: @admin, params: {anonymous: true})
    assert_empty poll.errors
    assert_not poll.reload.weighted_voting?
    PollService.update(poll: poll, actor: @admin, params: {anonymous: false, weighted_voting: true})
    assert_empty poll.errors
    assert poll.reload.weighted_voting?
    assert_equal BigDecimal('3'), poll.stances.latest.find_by!(participant: @voters.first).weight
    assert_equal BigDecimal('1'), poll.stances.latest.find_by!(participant: @voters.last).weight
  end

  test "switching modes does not re-enrol an excluded group voter" do
    poll = create_poll(specified_voters_only: false)
    excluded = @voters.first
    poll.stances.latest.find_by!(participant: excluded).update!(revoked_at: Time.current, revoker_id: @admin.id)
    eligible_ids = poll.stances.latest.pluck(:participant_id).sort

    PollService.update(poll: poll, actor: @admin, params: {anonymous: true})
    assert_empty poll.errors
    PollService.create_anonymous_poll_voters(poll: poll, actor: @admin, params: {})
    assert_not poll.anonymous_poll_voters.exists?(voter: excluded)

    PollService.update(poll: poll, actor: @admin, params: {anonymous: false})
    assert_empty poll.errors
    PollService.create_anyone_can_vote_stances(poll)
    assert_not poll.stances.latest.exists?(participant: excluded)
    assert_equal eligible_ids, poll.stances.latest.pluck(:participant_id).sort
  end

  private

  def electorate_and_votes(poll)
    [poll.stances.order(:id).map(&:attributes), poll.anonymous_poll_voters.order(:id).map(&:attributes),
      poll.anonymous_ballots.order(:id).map(&:attributes),
      StanceChoice.where(stance_id: poll.stances.select(:id)).order(:id).map(&:attributes)]
  end

  def create_poll(topic: topics(:discussion_topic), actor: @admin, voters: @voters, anonymous: false, **settings)
    poll = PollService.create(params: {
      title: 'Scheduled decision', topic_id: topic.id, poll_type: 'poll', poll_option_names: %w[Yes No],
      opening_at: 2.days.from_now, closing_at: 5.days.from_now, anonymous: anonymous,
      specified_voters_only: true, recipient_user_ids: voters.map(&:id), hide_results: 'until_closed', **settings
    }, actor: actor)
    PollService.create_stances(poll: poll, actor: actor, user_ids: voters.map(&:id)) unless anonymous
    poll.reload
  end
end
