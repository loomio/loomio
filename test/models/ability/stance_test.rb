require "test_helper"
require_relative "../../support/access_volume_matrix"

class Ability::StanceTest < ActiveSupport::TestCase
  test "identified stance reading and creation follow their poll access and voting rules" do
    actors = AccessVolumeMatrix::ROLES.map { |role| users(role) } + [users(:server_admin), LoggedOutUser.new]
    %i[discussion_topic direct_topic].each do |name|
      author = name == :direct_topic ? users(:guest_admin_normal) : users(:admin)
      poll = PollService.create(params: {
        topic_id: topics(name).id, title: 'Stance permission delegation', poll_type: 'proposal',
        poll_option_names: %w[Yes No], closing_at: 1.day.from_now
      }, actor: author)
      stance = poll.stances.latest.first!

      [false, true].each do |closed|
        PollService.close(poll: poll, actor: author) if closed
        actors.each do |actor|
          assert_equal actor.can?(:show, poll), actor.can?(:show, stance), "#{name}: read #{actor.id}"
          assert_equal actor.can?(:vote_in, poll), actor.can?(:create, stance), "#{name}: vote #{actor.id}"
        end
      end
    end
  end

  test "only an outstanding eligible voter invitation is redeemable" do
    poll = PollService.create(params: {
      topic_id: topics(:discussion_topic).id, title: 'Redeemable invitation', poll_type: 'proposal',
      poll_option_names: %w[Yes No], closing_at: 1.day.from_now
    }, actor: users(:admin))
    invitee = users(:guest_normal)
    stance = poll.stances.latest.find_by!(participant: invitee)
    stance.update!(inviter: users(:admin), accepted_at: nil)
    assert invitee.can?(:redeem, stance)

    stance.update!(accepted_at: Time.current)
    assert_not invitee.can?(:redeem, stance)
  end

  test "suspended or discarded groups block stance invitations and redaction" do
    group = groups(:group)
    coordinator = users(:member_normal)
    invitee = users(:guest_normal)
    group.add_admin!(coordinator)
    poll = PollService.create(params: {
      topic_id: topics(:discussion_topic).id, title: 'Suspended stance management', poll_type: 'proposal',
      poll_option_names: %w[Yes No], closing_at: 1.day.from_now
    }, actor: coordinator)
    stance = poll.stances.latest.find_by!(participant: invitee)
    stance.update!(inviter: coordinator, accepted_at: nil)
    redacted = poll.stances.latest.find_by!(participant: users(:member_loud))
    redacted.update!(redacted_at: Time.current)
    actions = [[invitee, :redeem, stance.id], [coordinator, :resend, stance.id],
               [coordinator, :redact, stance.id], [coordinator, :unredact, redacted.id]]
    actions.each { |actor, action, id| assert actor.can?(action, Stance.find(id)), action.to_s }

    group.update!(subscription: Subscription.create!(plan: 'free', state: 'on_hold'))
    actions.each { |actor, action, id| assert_not actor.can?(action, Stance.find(id)), "suspended: #{action}" }
    group.update!(subscription: nil)
    group.discard!
    actions.each { |actor, action, id| assert_not actor.can?(action, Stance.find(id)), "discarded: #{action}" }
  end
end
