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

    personal = PollSerializer.new(poll, scope: { exclude_types: [], current_user_id: voter.id }).as_json.fetch(:poll)
    assert_equal true, personal[:anonymous_voter_eligible]
    assert_equal false, personal[:anonymous_ballot_submitted]
    assert_equal true, personal[:voter_has_access]
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

  private

  def serialize_personal(poll, member)
    cache = RecordCache.for_collection([poll], member.id, %w[group reaction])
    PollSerializer.new(poll, scope: {cache: cache, current_user_id: member.id, exclude_types: %w[group reaction]}).as_json.fetch(:poll)
  end
end
