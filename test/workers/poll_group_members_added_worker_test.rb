require 'test_helper'

class PollGroupMembersAddedWorkerTest < ActiveSupport::TestCase
  test 'a deadlock retries partially completed membership synchronization without duplicating votes' do
    actor = users(:admin)
    group = Group.create!(name: 'Membership retry', group_privacy: 'secret')
    group.add_admin!(actor)
    polls = 2.times.map do
      PollService.create(params: {
        title: 'Membership retry poll', group_id: group.id, poll_type: 'proposal',
        closing_at: 1.day.from_now, poll_option_names: %w[agree disagree]
      }, actor: actor)
    end
    stance = polls.first.stances.latest.find_by!(participant_id: actor.id)
    option = polls.first.poll_options.first
    stance.choice = option.name
    stance.reason = 'Original vote'
    StanceService.create(stance: stance, actor: actor)
    assert_empty stance.errors
    assert stance.reload.cast_at
    original_vote = stance.reload.attributes
    member = users(:alien)
    group.add_member!(member)
    clear_enqueued_jobs

    create_stances = PollService.method(:create_anyone_can_vote_stances)
    attempts = 0
    interrupted_sync = lambda do |poll|
      attempts += 1
      raise ActiveRecord::Deadlocked, 'concurrent membership change' if attempts == 2

      create_stances.call(poll)
    end
    PollService.stub(:create_anyone_can_vote_stances, interrupted_sync) do
      assert_enqueued_with(job: PollGroupMembersAddedWorker, args: [group.id]) do
        PollGroupMembersAddedWorker.perform_now(group.id)
      end
    end
    assert_equal 1, Stance.latest.where(poll_id: polls.map(&:id), participant_id: member.id).count

    perform_enqueued_jobs(only: PollGroupMembersAddedWorker)

    polls.each do |poll|
      assert_equal 1, poll.stances.latest.where(participant_id: member.id).count
      assert member.can?(:vote_in, poll.reload)
      assert_equal 2, poll.vote_count_eligible
    end
    assert_equal original_vote, stance.reload.attributes
    assert_equal 1, polls.first.reload.vote_count_uncast
    assert_equal 2, polls.last.reload.vote_count_uncast
    assert_equal 1, option.reload.total_score.to_i
    assert_not users(:user).can?(:vote_in, polls.first)
    assert_not LoggedOutUser.new.can?(:vote_in, polls.first)
  end

  test 'retried synchronization preserves submitted anonymous ballots and excludes departed members' do
    actor = users(:admin)
    group = Group.create!(name: 'Anonymous membership retry', group_privacy: 'secret')
    group.add_admin!(actor)
    poll = PollService.create(params: {
      title: 'Anonymous retry poll', group_id: group.id, poll_type: 'proposal', anonymous: true,
      closing_at: 1.day.from_now, poll_option_names: %w[agree disagree]
    }, actor: actor)
    ballot = AnonymousBallotService.create(
      anonymous_ballot: poll.anonymous_ballots.build(
        anonymous_ballot_choices_attributes: [{poll_option_id: poll.poll_options.first.id, score: 1}]
      ), actor: actor
    )
    original_ballot = ballot.reload.attributes
    member = users(:alien)
    group.add_member!(member)
    departed = users(:user)
    membership = group.add_member!(departed)
    clear_enqueued_jobs

    PollService.stub(:group_members_added, ->(*) { raise ActiveRecord::Deadlocked, 'concurrent membership change' }) do
      assert_enqueued_with(job: PollGroupMembersAddedWorker, args: [group.id]) do
        PollGroupMembersAddedWorker.perform_now(group.id)
      end
    end
    MembershipService.revoke(membership: membership, actor: actor)
    perform_enqueued_jobs(only: PollGroupMembersAddedWorker)
    PollGroupMembersAddedWorker.perform_now(group.id)

    assert_equal original_ballot, ballot.reload.attributes
    assert_equal 1, poll.anonymous_ballots.count
    assert poll.anonymous_poll_voters.find_by!(voter_id: actor.id).ballot_submitted
    assert_not actor.can?(:vote_in, poll.reload)
    assert member.can?(:vote_in, poll)
    assert_not poll.anonymous_poll_voters.exists?(voter_id: departed.id)
    assert_not departed.can?(:vote_in, poll)
    assert_equal 2, poll.vote_count_eligible
    assert_equal 1, poll.vote_count_uncast
  end

  test 'adds stances for new group members even when the poll author has reached the invitation limit' do
    billing_env = ENV.slice('CHARGIFY_API_KEY', 'LOOMIO_SUBSCRIPTIONS')
    ENV.delete('CHARGIFY_API_KEY')
    ENV['LOOMIO_SUBSCRIPTIONS'] = 'enabled'

    author = User.create!(name: 'Demo Author', email: "demo-author-#{SecureRandom.hex(4)}@example.com", time_zone: 'UTC')
    group = Group.create!(
      name: 'Demo group',
      group_privacy: 'secret',
      subscription: Subscription.create!(plan: 'demo', max_members: nil)
    )
    group.add_admin!(author)
    poll = PollService.create(params: {
      title: 'Open demo poll', group_id: group.id, poll_type: 'proposal',
      closing_at: 1.day.from_now, poll_option_names: %w[agree disagree]
    }, actor: author)

    # Fill the author's default invitation quota (e.g. reused demo author across demo groups).
    UserInviter::DEFAULT_INVITATION_LIMIT.times do |i|
      invitee = User.create!(email: "prior-invitee-#{i}-#{SecureRandom.hex(4)}@example.com", time_zone: 'UTC')
      Membership.create!(user: invitee, group: Group.create!(name: "Other #{i}", group_privacy: 'secret'), inviter_id: author.id, accepted_at: Time.current)
    end

    member = users(:alien)
    group.add_member!(member)
    clear_enqueued_jobs

    assert AppConfig.app_features[:subscriptions]
    assert_raises(ThrottleService::LimitReached) do
      UserInviter.check_invitation_limit!(actor: author, user_ids: [member.id])
    end

    assert_nothing_raised do
      PollGroupMembersAddedWorker.perform_now(group.id)
    end

    assert_equal 1, poll.stances.latest.where(participant_id: member.id).count
    assert member.can?(:vote_in, poll.reload)
    assert_equal 2, poll.vote_count_eligible
  ensure
    %w[CHARGIFY_API_KEY LOOMIO_SUBSCRIPTIONS].each do |key|
      billing_env.key?(key) ? ENV[key] = billing_env[key] : ENV.delete(key)
    end
  end
end
