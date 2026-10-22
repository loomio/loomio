require "test_helper"

class Ability::PollAccessTest < ActiveSupport::TestCase
  test "group coordination permits starting polls when ordinary member poll creation is disabled" do
    group = groups(:group)
    coordinator = users(:member_normal)
    member = users(:member_loud)
    group.add_admin!(coordinator)
    group.update!(members_can_raise_motions: false)
    poll = PollService.build(params: poll_params(group_id: group.id), actor: coordinator)

    assert_not coordinator.is_admin?
    assert coordinator.can?(:create, poll)
    assert_not member.can?(:create, poll)
    group.update!(members_can_raise_motions: true)
    assert member.can?(:create, PollService.build(params: poll_params(group_id: group.id), actor: member))
  end

  test "a public template can be used outside its group but a private template cannot" do
    template = PollTemplate.create!(group: groups(:alien_group), author: users(:alien), process_name: 'Cross-group template', process_subtitle: 'Public template access', poll_type: 'proposal', public: true)
    actor = users(:member_normal)
    assert_not actor.groups.exists?(template.group_id)

    poll = PollService.create(params: poll_params(group_id: groups(:group).id, poll_template_id: template.id), actor: actor)
    assert_predicate poll, :persisted?
    template.update!(public: false)
    assert_raises CanCan::AccessDenied do
      PollService.create(params: poll_params(group_id: groups(:group).id, poll_template_id: template.id), actor: actor)
    end
  end

  test "anonymous voters remain in the electorate but cannot vote again after submitting" do
    voter = users(:guest_normal)
    %i[discussion_topic direct_topic].each do |fixture|
      coordinator = fixture == :direct_topic ? users(:guest_admin_normal) : users(:admin)
      poll = PollService.create(params: poll_params(topic_id: topics(fixture).id, anonymous: true), actor: coordinator)
      assert voter.can?(:vote_in, poll), fixture.to_s
      ballot = poll.anonymous_ballots.build(
        anonymous_ballot_choices_attributes: [{poll_option_id: poll.poll_options.first.id, score: 1}]
      )

      AnonymousBallotService.create(anonymous_ballot: ballot, actor: voter)

      assert_predicate ballot, :persisted?
      assert poll.reload.voters_unmasked.exists?(voter.id)
      assert_not voter.can?(:vote_in, poll), fixture.to_s
      assert_empty poll.stances
    end
  end

  test "ordinary direct-topic members can announce and remind only an open electorate poll" do
    topic = topics(:direct_topic)
    topic.update!(allow_concurrent_polls: true)
    coordinator = users(:guest_admin_normal)
    member = users(:guest_normal)
    outsider = users(:alien)
    [false, true].each do |specified|
      poll = PollService.create(params: poll_params(topic_id: topic.id, specified_voters_only: specified), actor: coordinator)
      %i[announce remind].each do |action|
        assert coordinator.can?(action, poll), action.to_s
        assert_equal !specified, member.can?(action, poll), action.to_s
        assert_not outsider.can?(action, poll), action.to_s
      end
    end
  end

  test "group coordinators can remind independently of the member announcement setting" do
    topic = topics(:discussion_topic)
    coordinator = users(:member_normal)
    author = users(:user)
    topic.group.add_admin!(coordinator)
    topic.group.update!(members_can_announce: false)
    poll = PollService.create(params: poll_params(topic_id: topic.id, specified_voters_only: true), actor: author)

    assert coordinator.can?(:remind, poll)
    assert_not author.can?(:remind, poll)
    topic.group.update!(members_can_announce: true)
    assert author.can?(:remind, Poll.find(poll.id))
  end

  test "reopening requires an identified closed poll in an unlocked topic" do
    topic = topics(:discussion_topic)
    topic.update!(allow_concurrent_polls: true)
    coordinator = users(:admin)
    identified = PollService.create(params: poll_params(topic_id: topic.id), actor: coordinator)
    anonymous = PollService.create(params: poll_params(topic_id: topic.id, anonymous: true), actor: coordinator)
    assert_not coordinator.can?(:reopen, identified)
    assert_not coordinator.can?(:reopen, anonymous)

    [identified, anonymous].each { |poll| PollService.close(poll: poll, actor: coordinator) }
    assert coordinator.can?(:reopen, identified)
    assert_not coordinator.can?(:reopen, anonymous)
    assert_not users(:member_normal).can?(:reopen, identified)

    TopicService.lock(topic: topic, actor: coordinator)
    assert_not coordinator.can?(:reopen, Poll.find(identified.id))
  end

  private

  def poll_params(**overrides)
    {title: 'Poll permission boundary', poll_type: 'proposal', poll_option_names: %w[Yes No], closing_at: 1.day.from_now}.merge(overrides)
  end
end
