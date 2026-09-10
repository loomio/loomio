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
