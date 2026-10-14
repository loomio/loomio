require 'test_helper'

class AccountPollHistoryTest < ActiveSupport::TestCase
  setup do
    @member = users(:member_normal)
    @admin = users(:admin)
    @group = groups(:group)
    @topic = topics(:discussion_topic)
    @topic.update!(allow_concurrent_polls: true)
  end

  # The existing access-control fixture matrix supplies the participant,
  # observers, revoked users, guests, and direct-topic roles used here.
  %w[deactivate redact].each do |operation|
    %w[off until_vote until_closed].each do |hide_results|
      test "#{operation} preserves ranked votes and reasons with #{hide_results} results" do
        poll = create_poll(hide_results: hide_results, poll_type: 'ranked_choice', minimum_stance_choices: 3)
        original = cast_vote(poll)
        original.update_columns(updated_at: 16.minutes.ago)
        replacement = StanceService.update(stance: original, actor: @member, params: {
          reason: 'Revised reason',
          stance_choices_attributes: poll.poll_options.order(:id).each_with_index.map do |option, index|
            {poll_option_id: option.id, score: [2, 3, 1].fetch(index)}
          end
        })
        assert replacement.errors.empty?, replacement.errors.full_messages.join(', ')
        assert_not_equal original.id, replacement.id
        ordinary_comment = Comment.new(parent: poll, body: 'An ordinary poll comment')
        CommentService.create(comment: ordinary_comment, actor: @member)
        voted_counts = poll.reload.attributes.slice('stance_counts', 'voters_count', 'undecided_voters_count', 'none_of_the_above_count')
        scores = replacement.option_scores
        pending_poll = create_poll
        pending_stance = pending_poll.stances.latest.find_by!(participant: @member)

        retire_account(operation)

        assert_nil original.reload.revoked_at
        assert_nil replacement.reload.revoked_at
        assert_equal scores, replacement.option_scores
        assert_equal 'Revised reason', replacement.reason
        assert_equal voted_counts, poll.reload.attributes.slice(*voted_counts.keys)
        assert_equal 1, poll.stances.latest.decided.where(participant: @member).count
        assert pending_stance.reload.revoked_at
        assert_not pending_poll.stances.latest.exists?(pending_stance.id)
        assert ordinary_comment.reload.kept?
        assert Membership.find_by!(group: @group, user: @member).revoked_at
        assert TopicReader.find_by!(topic: @topic, user: @member).revoked_at
        assert_not @member.reload.can?(:show, poll)
        assert_not @member.can?(:vote_in, poll)
        assert_raises(CanCan::AccessDenied) do
          StanceService.update(stance: replacement, actor: @member, params: {reason: 'Blocked change'})
        end
        assert_equal 'Revised reason', replacement.reload.reason

        serializer = StanceSerializer.new(replacement, scope: {current_user_id: users(:member_loud).id})
        assert_equal hide_results != 'until_closed', serializer.include_reason?
        assert_equal hide_results != 'until_closed', serializer.include_option_scores?
        assert_equal hide_results != 'until_closed', TopicItem.where(itemable: replacement).exists?
        assert_not users(:alien_quiet).can?(:show, poll)
        assert_not users(:former_member_loud).can?(:show, poll)
        assert_not LoggedOutUser.new.can?(:show, poll)
        assert users(:member_loud).can?(:show, poll)
        assert users(:guest_admin_normal).can?(:show, poll)
        assert_not users(:server_admin).can?(:show, poll)
        assert_equal operation == 'redact', @member.email.nil?
        assert_empty @member.sessions if operation == 'redact'

        PollService.close(poll: poll, actor: @admin)
        assert_equal scores, replacement.reload.option_scores
        assert_equal voted_counts.fetch('stance_counts'), poll.reload.stance_counts
        assert StanceSerializer.new(replacement, scope: {current_user_id: users(:member_loud).id}).include_reason?
        assert TopicItem.where(itemable: replacement).exists?
      end
    end
  end

  test 'deactivation keeps weighted results and quorum while removing only pending invitations' do
    poll = create_poll(weighted_voting: true, quorum_pct: 50)
    stance = cast_vote(poll)
    StanceService.set_weight(stance: stance, weight: '2.5', actor: @admin)
    counts = poll.reload.attributes.slice('stance_counts', 'voters_count', 'undecided_voters_count')
    quorum = [poll.quorum_count, poll.quorum_reached?]
    totals = poll.poll_options.order(:id).pluck(:total_score, :voter_weight_total, :voter_count)

    retire_account('deactivate')

    assert_equal counts, poll.reload.attributes.slice(*counts.keys)
    assert_equal quorum, [poll.quorum_count, poll.quorum_reached?]
    assert_equal totals, poll.poll_options.order(:id).pluck(:total_score, :voter_weight_total, :voter_count)
    assert_equal '2.5', VoteWeight.format(stance.reload.weight)
  end

  test 'account redaction does not restore votes previously removed by an administrator' do
    poll = create_poll
    stance = cast_vote(poll)
    stance.update!(revoked_at: 1.day.ago, revoker_id: @admin.id)
    poll.update_counts!
    revoked_at = stance.reload.revoked_at

    retire_account('redact')

    assert_equal revoked_at, stance.reload.revoked_at
    assert_equal @admin.id, stance.revoker_id
    assert_not poll.stances.latest.exists?(stance.id)
  end

  %i[member_normal admin].each do |role|
    test "group departure by #{role} still removes votes in open polls" do
      poll = create_poll
      stance = cast_vote(poll)
      membership = @group.membership_for(@member)
      actor = users(role)

      MembershipService.revoke(membership: membership, actor: actor)

      assert stance.reload.revoked_at
      assert_equal actor.id, stance.revoker_id
      assert_not poll.stances.latest.exists?(stance.id)
      assert_not @member.can?(:vote_in, poll)
    end
  end

  test 'deactivated-user membership cleanup retains submitted votes' do
    poll = create_poll
    stance = cast_vote(poll)
    @member.update!(deactivated_at: 1.hour.ago)

    RevokeMembershipsOfDeactivatedUsersWorker.perform_now

    assert_nil stance.reload.revoked_at
    assert Membership.find_by!(group: @group, user: @member).revoked_at
    assert_not @member.can?(:vote_in, poll)
  end

  test 'redaction retains anonymous ballots without creating identified vote records' do
    poll = create_poll(anonymous: true, poll_type: 'proposal')
    ballot = poll.anonymous_ballots.build(anonymous_ballot_choices_attributes: [
      {poll_option_id: poll.poll_options.first.id, score: 1}
    ])
    AnonymousBallotService.create(anonymous_ballot: ballot, actor: @member)
    counts = poll.reload.attributes.slice('stance_counts', 'voters_count', 'undecided_voters_count')

    retire_account('redact')

    assert_equal counts, poll.reload.attributes.slice(*counts.keys)
    assert poll.anonymous_ballots.exists?(ballot.id)
    assert_empty poll.stances
    assert_not @member.can?(:vote_in, poll)
    assert_not poll.results_available?
    assert_not TopicItem.where(itemable: ballot).exists?
  end

  test 'redaction retains votes in direct topics without allowing further participation' do
    @topic = topics(:direct_topic)
    @member = users(:guest_normal)
    @admin = users(:guest_admin_normal)
    poll = create_poll
    stance = cast_vote(poll)
    counts = poll.reload.stance_counts

    retire_account('redact')

    assert_nil stance.reload.revoked_at
    assert_equal counts, poll.reload.stance_counts
    assert_not @member.reload.can?(:show, poll)
    assert_not @member.can?(:vote_in, poll)
    assert users(:guest_loud).can?(:show, poll)
    assert_not users(:member_normal).can?(:show, poll)
    assert_not LoggedOutUser.new.can?(:show, poll)
  end

  test 'redaction retains public poll results without restoring member voting rights' do
    @topic = topics(:public_discussion_topic)
    @topic.group.add_member!(@admin)
    @topic.group.add_member!(@member)
    poll = create_poll
    stance = cast_vote(poll)

    retire_account('redact')

    assert_nil stance.reload.revoked_at
    assert LoggedOutUser.new.can?(:show, poll)
    assert_not LoggedOutUser.new.can?(:vote_in, poll)
    assert_not @member.reload.can?(:vote_in, poll)
    assert_nil @member[:name]
    assert_nil @member.email
    assert_equal I18n.t('profile_page.deleted_account'), @member.name
  end

  private

  def create_poll(**overrides)
    poll = PollService.create(params: {
      title: 'Account history poll', topic_id: @topic.id, poll_type: 'proposal',
      closing_at: 3.days.from_now, poll_option_names: ['One', 'Two', 'Three']
    }.merge(overrides), actor: @admin)
    assert poll.persisted?, poll.errors.full_messages.join(', ')
    poll
  end

  def cast_vote(poll)
    stance = poll.stances.latest.find_by!(participant: @member)
    stance.reason = 'Original reason'
    stance.choice = if poll.poll_type == 'ranked_choice'
      {'One' => 3, 'Two' => 2, 'Three' => 1}
    else
      'One'
    end
    StanceService.create(stance: stance, actor: @member)
    assert stance.errors.empty?, stance.errors.full_messages.join(', ')
    stance
  end

  def retire_account(operation)
    if operation == 'redact'
      NewsletterService.stub(:unsubscribe, nil) do
        RedactUserWorker.perform_now(@member.id, @member.id, false)
      end
    else
      DeactivateUserWorker.perform_now(@member.id, @member.id)
    end
  end
end
