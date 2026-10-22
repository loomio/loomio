require "test_helper"

class PollSerializerTest < ActiveSupport::TestCase
  test "shared payloads omit anonymous voter state instead of reporting false" do
    voter = users(:user)
    poll = PollService.create(
      params: {
        title: "Detached anonymous poll",
        poll_type: "proposal",
        closing_at: 3.days.from_now,
        group_id: groups(:group).id,
        anonymous: true,
        poll_option_names: ["Agree", "Disagree"]
      },
      actor: users(:admin)
    )

    shared = PollSerializer.new(poll, scope: { exclude_types: [] }).as_json.fetch(:poll)
    assert_not shared.key?(:anonymous_voter_eligible)
    assert_not shared.key?(:anonymous_ballot_submitted)
    assert_not shared.key?(:voter_has_access)
    %i[votes_cast_count votes_uncast_count participation_pct quorum_gap].each do |field|
      assert_not shared.key?(field), "open anonymous poll must omit #{field}"
    end

    personal = PollSerializer.new(poll, scope: { exclude_types: [], current_user_id: voter.id }).as_json.fetch(:poll)
    assert_equal true, personal[:anonymous_voter_eligible]
    assert_equal false, personal[:anonymous_ballot_submitted]
    assert_equal true, personal[:voter_has_access]

    PollService.close(poll: poll, actor: users(:admin))
    closed = PollSerializer.new(poll, scope: { exclude_types: [] }).as_json.fetch(:poll)
    assert_equal 0, closed[:votes_cast_count]
    assert_equal poll.voters_eligible_count, closed[:votes_uncast_count]
    assert_equal 0, closed[:participation_pct]
  end

  test "identified poll payload uses the new participation contract and still hides option totals" do
    poll = PollService.create(params: {
      title: 'Participation contract', poll_type: 'poll', group_id: groups(:group).id,
      hide_results: 'until_closed', poll_option_names: %w[Yes No], closing_at: 3.days.from_now
    }, actor: users(:admin))
    stance = poll.stances.latest.find_by!(participant: users(:admin))
    stance.choice = 'Yes'
    StanceService.create(stance: stance, actor: users(:admin))
    data = PollSerializer.new(poll.reload, scope: {exclude_types: []}).as_json.fetch(:poll)

    assert_equal 1, data[:votes_cast_count]
    assert_equal poll.voters_eligible_count - 1, data[:votes_uncast_count]
    assert_equal poll.voters_eligible_count, data[:voters_eligible_count]
    assert data.key?(:participation_pct)
    assert_not data.key?(:option_score_totals)
    %i[decided_voters_count undecided_voters_count voters_count cast_stances_pct stance_counts quorum_count quorum_votes_required].each do |field|
      assert_not data.key?(field), "retired field #{field}"
    end

    PollService.close(poll: poll, actor: users(:admin))
    closed = PollSerializer.new(poll, scope: {exclude_types: []}).as_json.fetch(:poll)
    assert_equal [1, 0], closed[:option_score_totals]
  end

  test "compact personal poll responses report revoked voting access without loading group records" do
    group = groups(:group)
    member = users(:member_normal)
    group.update!(is_visible_to_public: true, discussion_privacy_options: 'public_or_private')
    polls = [false, true].map do |anonymous|
      PollService.create(params: {
        title: 'Public voting access', poll_type: 'poll', group_id: group.id,
        private: false, anonymous: anonymous, poll_option_names: %w[Yes No], closing_at: 3.days.from_now
      }, actor: users(:admin))
    end
    polls.each do |poll|
      assert_equal true, serialize_personal(poll, member)[:voter_has_access]
    end

    PollService.close(poll: polls.first, actor: users(:admin))
    MembershipService.revoke(membership: group.membership_for(member), actor: member)
    PollService.reopen(poll: polls.first, actor: users(:admin), params: {closing_at: 3.days.from_now})
    polls.each do |poll|
      assert member.can?(:show, poll)
      assert_equal false, serialize_personal(poll, member)[:voter_has_access]
    end

    group.add_member!(member)
    polls.each do |poll|
      assert_equal true, serialize_personal(poll, member)[:voter_has_access]
    end
  end

  test "compact poll voting access queries memberships once for the response" do
    member = users(:member_normal)
    polls = 3.times.map do
      PollService.create(params: {
        title: 'Batched voting access', poll_type: 'poll', group_id: groups(:group).id,
        poll_option_names: %w[Yes No], closing_at: 3.days.from_now
      }, actor: users(:admin))
    end
    cache = RecordCache.for_collection(polls, member.id, %w[group reaction])
    queries = []
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |_name, _start, _end, _id, payload|
      queries << payload[:sql] if payload[:sql].start_with?('SELECT "memberships"."group_id" FROM "memberships"') && !payload[:cached]
    end

    ActiveRecord::Base.uncached do
      polls.each do |poll|
        data = PollSerializer.new(poll, scope: {cache: cache, current_user_id: member.id, exclude_types: %w[group reaction]}).as_json
        assert_equal true, data.fetch(:poll).fetch(:voter_has_access)
      end
    end
    assert_equal 1, queries.length
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end

  test "full poll responses reuse cached membership presence and absence for voting access" do
    poll = PollService.create(params: {
      title: 'Cached voting access', poll_type: 'poll', topic: topics(:discussion_topic),
      poll_option_names: %w[Yes No], closing_at: 3.days.from_now
    }, actor: users(:admin))
    queries = []
    subscriber = ActiveSupport::Notifications.subscribe('sql.active_record') do |_name, _start, _end, _id, payload|
      queries << payload[:sql] if payload[:sql].start_with?('SELECT "memberships"."group_id" FROM "memberships"') && !payload[:cached]
    end

    %i[member_normal guest_normal alien non_guest_loud former_member_loud former_guest_loud].each do |role|
      viewer = users(role)
      cache = RecordCache.for_collection([poll], viewer.id)
      ActiveRecord::Base.uncached do
        data = PollSerializer.new(poll, scope: {cache: cache, current_user_id: viewer.id, exclude_types: []}).as_json.fetch(:poll)
        expected = %i[member_normal guest_normal].include?(role)
        assert_equal expected, data[:voter_has_access], role.to_s
      end
    end

    assert_empty queries
  ensure
    ActiveSupport::Notifications.unsubscribe(subscriber) if subscriber
  end

  private

  def serialize_personal(poll, member)
    cache = RecordCache.for_collection([poll], member.id, %w[group reaction])
    PollSerializer.new(poll, scope: {cache: cache, current_user_id: member.id, exclude_types: %w[group reaction]}).as_json.fetch(:poll)
  end
end
