require 'test_helper'

class PollQueryTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @group = groups(:group)
    @discussion = discussions(:discussion)

    def make_poll(**attrs)
      defaults = {
        poll_type: "poll",
        title: "Test poll #{SecureRandom.hex(4)}",
        poll_option_names: ["engage"],
        closing_at: 5.days.from_now,
        notify_on_closing_soon: "voters"
      }
      p = PollService.build(params: defaults.merge(attrs), actor: attrs[:author] || @user)
      p.save!
      p.create_missing_created_topic_item!
      p
    end

    @closed_long_ago  = make_poll.tap { |p| p.update_columns(closed_at: 1.month.ago, closing_at: 1.month.ago) }
    @closed_soon      = make_poll.tap { |p| p.update_columns(closed_at: 1.day.ago, closing_at: 1.day.ago) }
    @closing_soon     = make_poll(closed_at: nil, closing_at: 1.day.from_now)
    @closing_far_away = make_poll(closed_at: nil, closing_at: 1.month.from_now)

    @authored = make_poll(closing_at: 5.days.from_now)

    hex = SecureRandom.hex(4)
    @guest_user = User.create!(name: "pollguest#{hex}", email: "pollguest#{hex}@example.com", username: "pollguest#{hex}")
    @participated = make_poll(closing_at: 5.days.from_now)
    @participated.stances.create!(participant_id: @user.id, inviter: @authored.author)
    @participated.add_guest!(@user, @authored.author)

    @in_a_discussion = make_poll(topic: @discussion.topic, closing_at: 5.days.from_now)
    @in_a_group = PollService.create(params: { title: "In group #{SecureRandom.hex(4)}", poll_type: 'poll', group_id: @group.id, closing_at: 5.days.from_now, poll_option_names: ['engage'] }, actor: @user)

    hex2 = SecureRandom.hex(4)
    rando_author = User.create!(name: "rando#{hex2}", email: "rando#{hex2}@example.com", username: "rando#{hex2}")
    @rando = make_poll(author: rando_author, closing_at: 5.days.from_now)
    other_group = Group.create!(name: "Other Group #{hex2}", handle: "othergroup#{hex2}")
    other_group.add_admin!(rando_author)
    @rando_in_group = PollService.create(params: { title: "Rando group #{SecureRandom.hex(4)}", poll_type: 'poll', group_id: other_group.id, closing_at: 5.days.from_now, poll_option_names: ['engage'] }, actor: rando_author)

    ActionMailer::Base.deliveries.clear
  end

  test "archival excludes public private and anonymous polls from every visibility entry point" do
    group_poll = @in_a_group
    public_poll = make_poll(topic: topics(:public_discussion_topic), private: false)
    anonymous_poll = make_poll(topic: topics(:discussion_topic), anonymous: true)
    groups(:group).discard!
    groups(:public_group).discard!
    actors = %i[admin user member_normal guest_normal guest_admin_normal alien_loud
                non_guest_loud former_guest_loud inactive_guest_loud].map { |role| users(role) }
    actors << LoggedOutUser.new
    actors << LoggedOutUser.new(params: {topic_reader_token: topic_readers(:guest_normal_reader).token})

    [group_poll, public_poll, anonymous_poll].each do |poll|
      [nil, Time.current].each do |closed_at|
        poll.update_column(:closed_at, closed_at)
        actors.each do |actor|
          assert_not PollQuery.visible_to(user: actor).exists?(poll.id)
          assert_not PollQuery.visible_to(user: actor, chain: Poll.all).exists?(poll.id)
          assert_not PollQuery.relevant_to(user: actor, group_ids: [poll.group_id]).exists?(poll.id)
          assert_not actor.can?(:show, poll.reload)
        end
      end
    end
    assert PollQuery.visible_to(user: @user).exists?(@authored.id)
  end

  test "finds polls the user knows about" do
    results = PollQuery.visible_to(user: @user)
    assert_includes results, @participated
    assert_includes results, @in_a_discussion
    assert_includes results, @in_a_group
    refute_includes results, @rando_in_group
    refute_includes results, @rando
  end

  test "deactivated users cannot see polls" do
    @user.update!(deactivated_at: Time.current)

    assert_empty PollQuery.visible_to(user: @user)
  end

  test "need vote filters the viewer's pending stance rather than other people's votes" do
    viewer = users(:member_normal)
    other = users(:member_loud)
    poll = @in_a_group
    viewer_stance = poll.stances.latest.find_by!(participant: viewer)
    other_stance = poll.stances.latest.find_by!(participant: other)
    chain = PollQuery.relevant_to(user: viewer)
    pending = -> { PollQuery.filter(chain: chain, params: {status: 'vote'}, user: viewer) }

    assert pending.call.exists?(poll.id)
    other_stance.update_column(:cast_at, Time.current)
    assert pending.call.exists?(poll.id)
    viewer_stance.update_column(:cast_at, Time.current)
    assert_not pending.call.exists?(poll.id)
    viewer_stance.update_column(:cast_at, nil)
    assert pending.call.exists?(poll.id)
    viewer_stance.update_column(:revoked_at, Time.current)
    assert_not pending.call.exists?(poll.id)
    viewer_stance.update_column(:revoked_at, nil)
    poll.update_column(:closed_at, Time.current)
    assert_not pending.call.exists?(poll.id)
    poll.update_columns(closed_at: nil, closing_at: 1.minute.ago)
    assert_not pending.call.exists?(poll.id)
    poll.update_columns(closing_at: 3.days.from_now, opened_at: nil)
    assert_not pending.call.exists?(poll.id)
    assert_empty PollQuery.filter(chain: chain, params: {status: 'vote'})
  end

  test "need vote uses anonymous submission state and excludes viewers outside the electorate" do
    viewer = users(:member_normal)
    poll = PollService.create(params: {
      title: 'Anonymous pending votes', poll_type: 'poll', anonymous: true,
      group_id: @group.id, specified_voters_only: true,
      recipient_user_ids: [viewer.id, users(:member_loud).id],
      poll_option_names: %w[Yes No], closing_at: 3.days.from_now
    }, actor: users(:admin))
    pending = ->(user) {
      PollQuery.filter(chain: PollQuery.relevant_to(user: user), params: {status: 'vote'}, user: user)
    }

    assert pending.call(viewer).exists?(poll.id)
    assert_not pending.call(users(:member_quiet)).exists?(poll.id)
    poll.anonymous_poll_voters.find_by!(voter: users(:member_loud)).update!(ballot_submitted: true)
    assert pending.call(viewer).exists?(poll.id)
    poll.anonymous_poll_voters.find_by!(voter: viewer).update!(ballot_submitted: true)
    assert_not pending.call(viewer).exists?(poll.id)
  end

  test "leaving a group removes authored STV polls from visibility and relevance" do
    author = users(:member_normal)
    poll = PollService.create(params: {
      title: 'Working group election', poll_type: 'stv', group_id: @group.id,
      poll_option_names: %w[Alex Blair Casey], stv_seats: 1,
      closing_at: 3.days.from_now
    }, actor: author)
    assert PollQuery.relevant_to(user: author).exists?(poll.id)
    assert_not poll.stances.latest.cast.exists?(participant_id: author.id)

    MembershipService.revoke(membership: @group.membership_for(author), actor: author)
    author.reload

    [nil, Time.current].each do |closed_at|
      poll.update_column(:closed_at, closed_at)
      assert_not PollQuery.visible_to(user: author).exists?(poll.id)
      assert_not PollQuery.visible_to(user: author, chain: Poll.all).exists?(poll.id)
      assert_not PollQuery.relevant_to(user: author).exists?(poll.id)
      assert_not PollQuery.relevant_to(user: author, group_ids: [@group.id]).exists?(poll.id)
      assert_not author.can?(:show, poll)
      assert_not author.can?(:export, poll)
      assert users(:admin).can?(:show, poll)
    end
  end

  test "authorship does not bypass the group topic access matrix" do
    topics(:discussion_topic).update!(polls_one_at_a_time: false)
    users(:alien).update!(is_admin: true)
    roles = %i[admin member_normal guest_normal guest_admin_normal alien
               non_guest_loud former_member_loud former_guest_loud
               inactive_member_loud inactive_guest_loud]

    [false, true].each do |anonymous|
      poll = PollService.create(params: {
        title: 'Private group poll', poll_type: 'proposal',
        topic_id: topics(:discussion_topic).id, anonymous: anonymous,
        poll_option_names: %w[agree disagree], closing_at: 3.days.from_now
      }, actor: users(:admin))
      hide_results_modes = anonymous ? %w[until_closed] : %w[off until_vote until_closed]

      hide_results_modes.each do |hide_results|
        [nil, Time.current].each do |closed_at|
          poll.update_columns(hide_results: hide_results, closed_at: closed_at)
          roles.each do |role|
            author = users(role)
            poll.update_column(:author_id, author.id)
            expected = %i[admin member_normal guest_normal guest_admin_normal].include?(role)
            label = "#{role}, anonymous=#{anonymous}, results=#{hide_results}, closed=#{closed_at.present?}"
            assert_equal expected, TopicQuery.visible_to(user: author).exists?(poll.topic_id), label
            assert_equal expected, PollQuery.visible_to(user: author).exists?(poll.id), label
            assert_equal expected, PollQuery.visible_to(user: author, topic_id: poll.topic_id).exists?(poll.id), label
            assert_equal expected, PollQuery.relevant_to(user: author).exists?(poll.id), label
            assert_equal expected, author.can?(:show, poll), label
          end
          assert_not LoggedOutUser.new.can?(:show, poll)
        end
      end
    end
  end

  test "direct poll authors retain visibility and relevance without a group membership" do
    assert_nil @authored.group_id
    assert PollQuery.visible_to(user: @user).exists?(@authored.id)
    assert PollQuery.visible_to(user: @user, topic_id: @authored.topic_id).exists?(@authored.id)
    assert PollQuery.relevant_to(user: @user).exists?(@authored.id)
    assert @user.can?(:show, @authored)
    assert_not users(:alien).can?(:show, @authored)
  end

  test "guest tokens grant poll access only for active guest readers" do
    %i[guest_normal_reader direct_guest_normal_reader
       former_guest_loud_reader direct_former_guest_reader
       non_guest_loud_reader direct_non_guest_reader].each do |role|
      reader = topic_readers(role)
      poll = make_poll(topic: reader.topic)
      viewer = LoggedOutUser.new(params: {topic_reader_token: reader.token})
      expected = reader.revoked_at.nil? && reader.guest?

      assert_equal expected, PollQuery.visible_to(user: viewer).exists?(poll.id), role
      assert_equal expected, PollQuery.visible_to(user: viewer, topic_id: poll.topic_id).exists?(poll.id), role
      assert_equal expected, PollQuery.relevant_to(user: viewer).exists?(poll.id), role
      assert_equal expected, viewer.can?(:show, poll), role
      assert_not viewer.can?(:vote_in, poll), role
    end
  end

  test "browsing guest groups does not grant access to their other private polls" do
    guest = users(:guest_normal)
    invited_poll = make_poll(topic: topics(:discussion_topic))
    private_poll = @in_a_group
    membership_ids = guest.group_ids.dup

    assert GroupQuery.visible_to(user: guest).exists?(@group.id)
    assert_equal membership_ids, guest.group_ids
    assert TopicQuery.visible_to(user: guest).exists?(invited_poll.topic_id)
    assert_not TopicQuery.visible_to(user: guest).exists?(private_poll.topic_id)
    assert PollQuery.visible_to(user: guest).exists?(invited_poll.id)
    assert PollQuery.relevant_to(user: guest).exists?(invited_poll.id)
    assert_not PollQuery.visible_to(user: guest).exists?(private_poll.id)
    assert_not PollQuery.relevant_to(user: guest).exists?(private_poll.id)
    assert_not guest.can?(:show, private_poll)
  end

  test "checking payment does not grant subgroup members access to private parent polls" do
    member = users(:subgroup_user)
    membership_ids = member.group_ids.dup
    assert_not member.group_ids.include?(@group.id)

    member.is_paying?

    assert_equal membership_ids, member.group_ids
    assert_not TopicQuery.visible_to(user: member).exists?(@in_a_group.topic_id)
    assert_not PollQuery.visible_to(user: member).exists?(@in_a_group.id)
    assert_not PollQuery.relevant_to(user: member).exists?(@in_a_group.id)
    assert_not member.can?(:show, @in_a_group)
  end

  test "topic access preserves custom poll scopes and excludes discarded topics" do
    chain = Poll.where(id: [@authored.id, @in_a_group.id])
    assert_equal [@in_a_group.id],
                 PollQuery.visible_to(user: @user, chain: chain, topic_id: @in_a_group.topic_id).pluck(:id)
    assert_not PollQuery.visible_to(user: @user, topic_id: @authored.topic_id).exists?(@in_a_group.id)
    %i[visible_to relevant_to].each do |query|
      assert_equal [@authored.id, @in_a_group.id].sort,
                   PollQuery.public_send(query, user: @user, chain: chain).pluck(:id).sort
    end

    [@authored, @in_a_group].each { |poll| poll.topic.update_column(:discarded_at, Time.current) }
    %i[visible_to relevant_to].each do |query|
      assert_empty PollQuery.public_send(query, user: @user, chain: chain)
    end
  end

  test "dashboard visibility includes polls for topic reader guests" do
    hex = SecureRandom.hex(4)
    private_group = Group.create!(name: "Guest poll group #{hex}", handle: "guestpollgroup#{hex}")
    poll_author = User.create!(name: "guestpoll#{hex}", email: "guestpoll#{hex}@example.com", username: "guestpoll#{hex}")
    private_group.add_admin!(poll_author)
    guest_poll = PollService.create(params: {
      title: "Guest poll #{hex}",
      poll_type: "poll",
      private: true,
      group_id: private_group.id,
      closing_at: 5.days.from_now,
      poll_option_names: ["engage"]
    }, actor: poll_author)
    guest_poll.add_guest!(@user, poll_author)

    private_poll = PollService.create(params: {
      title: "Private poll #{hex}",
      poll_type: "poll",
      private: true,
      group_id: private_group.id,
      closing_at: 5.days.from_now,
      poll_option_names: ["ignore"]
    }, actor: poll_author)

    results = PollQuery.visible_to(user: @user).recent
    assert_includes results, guest_poll
    refute_includes results, private_poll
  end

  test "public visibility uses topic privacy not group discussion privacy options" do
    hex = SecureRandom.hex(4)
    public_group = Group.new(
      name: "Public mixed privacy #{hex}",
      is_visible_to_public: true,
      discussion_privacy_options: "public_or_private"
    )
    public_group.save(validate: false)
    public_author = User.create!(name: "publicpoll#{hex}", email: "publicpoll#{hex}@example.com", username: "publicpoll#{hex}")
    public_group.add_admin!(public_author)
    public_poll = PollService.create(params: {
      title: "Public mixed privacy poll #{hex}",
      poll_type: "poll",
      private: false,
      group_id: public_group.id,
      closing_at: 5.days.from_now,
      poll_option_names: ["engage"]
    }, actor: public_author)

    assert_includes PollQuery.visible_to(user: @user), public_poll
    refute_includes PollQuery.relevant_to(user: @user), public_poll
    assert_includes PollQuery.relevant_to(user: @user, group_ids: [public_group.id]), public_poll

    MembershipService.revoke(membership: public_group.membership_for(public_author), actor: public_author)
    public_author.reload
    assert PollQuery.visible_to(user: public_author).exists?(public_poll.id)
    assert_not PollQuery.relevant_to(user: public_author).exists?(public_poll.id)
    assert PollQuery.relevant_to(user: public_author, group_ids: [public_group.id]).exists?(public_poll.id)
  end

  test "subgroup poll visibility matches the fixture access matrix for parent members" do
    child, poll = create_subgroup_poll(parent_members_can_see_discussions: true)

    subgroup_poll_members.each do |user|
      assert PollQuery.visible_to(user: user).exists?(poll.id), "direct access for #{user.email}"
      assert PollQuery.relevant_to(user: user).exists?(poll.id), "dashboard access for #{user.email}"
      assert PollQuery.relevant_to(user: user, group_ids: [ child.id ]).exists?(poll.id), "subgroup access for #{user.email}"
      assert user.can?(:show, poll), "show permission for #{user.email}"
      assert user.can?(:vote_in, poll), "vote permission for #{user.email}"
    end

    parent_only_members.each do |user|
      assert PollQuery.visible_to(user: user).exists?(poll.id), "direct access for #{user.email}"
      refute PollQuery.relevant_to(user: user).exists?(poll.id), "dashboard access for #{user.email}"
      assert PollQuery.relevant_to(user: user, group_ids: [ child.id ]).exists?(poll.id), "subgroup access for #{user.email}"
      assert user.can?(:show, poll), "show permission for #{user.email}"
      refute user.can?(:vote_in, poll), "vote permission for #{user.email}"
    end

    denied_poll_viewers.each do |user|
      label = user.is_logged_in? ? user.email : "signed-out user"
      refute PollQuery.visible_to(user: user).exists?(poll.id), "direct access for #{label}"
      refute PollQuery.relevant_to(user: user).exists?(poll.id), "dashboard access for #{label}"
      refute PollQuery.relevant_to(user: user, group_ids: [ child.id ]).exists?(poll.id), "subgroup access for #{label}"
      refute user.can?(:show, poll), "show permission for #{label}"
      refute user.can?(:vote_in, poll), "vote permission for #{label}"
    end

  end

  test "parent members cannot see subgroup polls when parent member access is false" do
    child, poll = create_subgroup_poll(parent_members_can_see_discussions: false)

    subgroup_poll_members.each do |user|
      assert PollQuery.visible_to(user: user).exists?(poll.id), "direct access for #{user.email}"
      assert PollQuery.relevant_to(user: user).exists?(poll.id), "dashboard access for #{user.email}"
      assert PollQuery.relevant_to(user: user, group_ids: [ child.id ]).exists?(poll.id), "subgroup access for #{user.email}"
      assert user.can?(:show, poll), "show permission for #{user.email}"
      assert user.can?(:vote_in, poll), "vote permission for #{user.email}"
    end

    (parent_only_members + denied_poll_viewers).each do |user|
      label = user.is_logged_in? ? user.email : "signed-out user"
      refute PollQuery.visible_to(user: user).exists?(poll.id), "direct access for #{label}"
      refute PollQuery.relevant_to(user: user).exists?(poll.id), "dashboard access for #{label}"
      refute PollQuery.relevant_to(user: user, group_ids: [ child.id ]).exists?(poll.id), "subgroup access for #{label}"
      refute user.can?(:show, poll), "show permission for #{label}"
      refute user.can?(:vote_in, poll), "vote permission for #{label}"
    end
  end

  private

  def create_subgroup_poll(parent_members_can_see_discussions:)
    child = groups(:subgroup)
    child.update_columns(
      is_visible_to_public: false,
      is_visible_to_parent_members: true,
      parent_members_can_see_discussions: parent_members_can_see_discussions
    )
    poll = PollService.create(params: {
      title: "Subgroup poll #{SecureRandom.hex(4)}",
      poll_type: "poll",
      private: true,
      group_id: child.id,
      closing_at: 5.days.from_now,
      poll_option_names: [ "engage" ]
    }, actor: users(:admin))
    [ child, poll ]
  end

  def subgroup_poll_members
    users(:admin, :user, :subgroup_user)
  end

  def parent_only_members
    users(
      :member,
      :member_quiet,
      :member_normal,
      :member_loud,
      :reader_quiet,
      :reader_normal,
      :reader_loud,
      :member_guest_loud
    )
  end

  def denied_poll_viewers
    users(
      :guest_quiet,
      :guest_normal,
      :guest_admin_normal,
      :guest_loud,
      :alien,
      :alien_quiet,
      :alien_loud,
      :non_guest_loud,
      :former_member_loud,
      :former_guest_loud,
      :inactive_member_loud,
      :inactive_guest_loud,
      :former_member_guest
    ) + [ LoggedOutUser.new ]
  end
end
