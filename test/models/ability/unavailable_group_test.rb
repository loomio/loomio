require "test_helper"

class Ability::UnavailableGroupTest < ActiveSupport::TestCase
  test "discarded and subscription-inactive groups have the same access boundary" do
    group = groups(:group)
    topic = topics(:discussion_topic)
    member = users(:member_normal)
    admin = group.admins.first
    direct_topic = topics(:direct_topic)
    subscription = Subscription.create!(plan: "free", state: "active")
    group.update!(subscription: subscription)

    assert group.available?
    assert admin.can?(:export, group)
    assert member.can?(:show, topic.discussion)
    assert member.can?(:create, Comment.new(parent: topic.discussion))

    ["on_hold", "past_due", "canceled"].each do |state|
      subscription.update!(state: state, expires_at: nil)
      assert_not group.reload.available?, state
      assert admin.can?(:export, group), state
      assert_not member.can?(:show, topic.discussion), state
      assert_not member.can?(:create, Comment.new(parent: topic.discussion)), state
      assert_empty TopicQuery.visible_to(user: member, topic_id: topic.id), state
    end

    subscription.update!(state: "active", expires_at: 1.second.ago)
    assert_not group.reload.available?
    assert_not member.can?(:show, topic.discussion)
    assert_empty TopicQuery.visible_to(user: member, topic_id: topic.id)

    group.update!(subscription: nil)
    assert group.reload.available?
    assert member.can?(:show, topic.discussion)
    assert users(:guest_admin_normal).can?(:show, direct_topic)
  end

  test "group admins must export before discarding a group" do
    group = groups(:group)
    admin = group.admins.first

    assert admin.can?(:export, group)

    group.discard!

    assert_not admin.can?(:export, group.reload)
  end

  test "discard denies new content and voting across the access matrix" do
    topic = topics(:discussion_topic)
    poll = PollService.create(params: poll_params(topic_id: topic.id), actor: users(:admin))
    roles = %i[admin user member_normal guest_normal guest_admin_normal alien_loud
               non_guest_loud former_member_loud former_guest_loud inactive_member_loud inactive_guest_loud]
    assert users(:member_normal).can?(:create, Comment.new(parent: topic.discussion))
    assert users(:guest_normal).can?(:vote_in, poll)

    groups(:group).discard!
    topic.reload
    poll.reload
    actors = roles.map { |role| users(role) } + [LoggedOutUser.new]
    actors.each do |actor|
      assert_not actor.can?(:create, Comment.new(parent: topic.discussion)), actor.inspect
      assert_not actor.can?(:create, DiscussionService.build(params: {title: "Discarded", group_id: topic.group_id}, actor: users(:admin)))
      assert_not actor.can?(:create, PollService.build(params: poll_params(topic_id: topic.id), actor: users(:admin)))
      Poll.hide_results.keys.each do |mode|
        poll.assign_attributes(hide_results: mode, quorum_pct: 50)
        assert_not actor.can?(:vote_in, poll)
      end
    end
  end

  test "discarded content creation services reject requests without writing records" do
    topic = topics(:discussion_topic)
    poll = PollService.create(params: poll_params(topic_id: topic.id), actor: users(:admin))
    groups(:group).discard!
    topic.reload
    poll.reload
    actor = users(:member_normal)
    stance = poll.stances.latest.find_by!(participant: actor)
    stance.update_column(:cast_at, Time.current)
    assert_not actor.can?(:update, stance)
    assert_not actor.can?(:uncast, stance)

    assert_no_difference ["Comment.count", "Discussion.count", "Poll.count", "Stance.count", "TopicItem.count", "Notification.count"] do
      assert_raises(CanCan::AccessDenied) do
        CommentService.create(comment: Comment.new(parent: topic.discussion, body: "Blocked"), actor: actor)
      end
      assert_raises(CanCan::AccessDenied) do
        DiscussionService.create(params: {title: "Blocked", group_id: topic.group_id}, actor: actor)
      end
      assert_raises(CanCan::AccessDenied) do
        PollService.create(params: poll_params(topic_id: topic.id), actor: actor)
      end
      assert_raises(CanCan::AccessDenied) do
        StanceService.create(stance: Stance.new(poll: poll), actor: actor)
      end
    end
  end

  test "public groups and inherited subgroup discard block new activity" do
    %i[public_discussion_topic subgroup_discussion_topic].each do |name|
      topic = topics(name)
      actor = topic.discussion.author
      topic.group.add_admin!(actor)
      assert actor.can?(:create, Comment.new(parent: topic.discussion))
      (name == :subgroup_discussion_topic ? groups(:group) : topic.group).discard!
      topic.reload
      assert_not actor.can?(:create, Comment.new(parent: topic.discussion))
      assert_not actor.can?(:create, DiscussionService.build(params: {title: "Discarded", group_id: topic.group_id}, actor: actor))
    end
  end

  test "direct topics retain member access and reject nonmembers after a group is discarded" do
    groups(:group).discard!
    topic = topics(:direct_topic)
    actor = users(:guest_admin_normal)
    comment = CommentService.create(comment: Comment.new(parent: topic.discussion, body: "Direct comment"), actor: actor)
    assert comment.persisted?
    poll = PollService.create(params: poll_params(topic_id: topic.id), actor: actor)
    assert poll.persisted?
    assert_nil topic.group.discarded_at
    stance = StanceService.update(
      stance: poll.stances.latest.find_by!(participant: users(:guest_normal)),
      params: {stance_choices_attributes: [{poll_option_id: poll.poll_options.first.id, score: 1}]},
      actor: users(:guest_normal)
    )
    assert stance.persisted?
    assert stance.cast_at

    %i[guest_normal guest_admin_normal guest_loud].each do |role|
      assert users(role).can?(:create, Comment.new(parent: topic.discussion))
      assert users(role).can?(:vote_in, poll)
    end
    %i[member_normal non_guest_loud former_guest_loud inactive_guest_loud].each do |role|
      assert_not users(role).can?(:create, Comment.new(parent: topic.discussion))
      assert_not users(role).can?(:vote_in, poll)
    end
    discussion = DiscussionService.create(params: {title: "Direct discussion"}, actor: users(:alien))
    assert discussion.persisted?
    assert_nil discussion.group.discarded_at
    poll.update!(closed_at: Time.current)
    assert_not actor.can?(:vote_in, poll)
  end

  test "discard suspends content management and invitations while retaining cleanup" do
    topic = topics(:discussion_topic)
    admin = users(:admin)
    poll = PollService.create(params: poll_params(topic_id: topic.id), actor: admin)
    comment = CommentService.create(comment: Comment.new(parent: topic.discussion, body: "Before discard"), actor: admin)
    outcome = Outcome.new(poll: poll, author: admin, statement: "Conclusion")
    membership = memberships(:member_membership)
    reader = topic_readers(:guest_normal_reader)
    request = MembershipRequest.new(group: topic.group, requestor: users(:alien))
    records = {
      topic.discussion => %i[show print update update_version announce destroy discard],
      topic => %i[show update move move_comments pin close reopen discard update_tags announce members_autocomplete add_members add_guests],
      comment => %i[show update discard undiscard destroy],
      poll => %i[show export receipts update announce remind add_voters close reopen destroy],
      outcome => %i[show create update announce add_members add_guests],
      comment.created_topic_item => %i[pin unpin],
      PollTemplate.new(group: topic.group, author: admin) => %i[create update],
      DiscussionTemplate.new(group: topic.group, author: admin) => %i[create update],
      Tag.new(group: topic.group) => %i[show create update destroy],
      Chatbot.new(group: topic.group, author: admin) => %i[create update test],
      membership => %i[make_admin make_delegate resend],
      reader => %i[make_admin resend redeem],
      request => %i[show approve]
    }
    assert admin.can?(:update, topic.discussion)
    assert admin.can?(:remind, poll)
    assert admin.can?(:make_admin, reader)
    group = topic.group
    group.discard!
    records.each_key { |record| record.reload if record.persisted? }
    # Unsaved records can still hold their group's pre-discard association.
    records.each_key { |record| record.group.reload if record.respond_to?(:group) && record.group.present? }

    [admin, users(:member_normal), users(:guest_admin_normal), LoggedOutUser.new].each do |actor|
      records.each do |record, actions|
        actions.each { |action| assert_not actor.can?(action, record), "#{actor.id}: #{action} #{record.class}" }
      end
      %i[update publish export email_members view_pending_invitations members_autocomplete show_chatbots
         move_discussions_to add_guests add_members invite_people announce manage_membership_requests
         notify add_subgroup].each do |action|
        assert_not actor.can?(action, group), action
      end
      assert_not actor.can?(:create, Group.new(parent: group))
    end

    assert admin.can?(:destroy, group)
    %i[remove_admin revoke destroy remove_delegate].each { |action| assert admin.can?(action, membership), action }
    assert membership.user.can?(:update, membership)
    assert_not admin.can?(:update, membership)
    assert admin.can?(:remove, reader)
    assert admin.can?(:remove_admin, reader)
    assert reader.user.can?(:update, reader)
    assert admin.can?(:destroy, Chatbot.new(group: group))
  end

  test "instance admins can move and merge unavailable groups" do
    admin = users(:admin)
    group = groups(:group)
    group.discard!

    assert admin.can?(:move, group)
    assert admin.can?(:merge, group)
  end

  test "discarding an unrelated group preserves all existing direct topic management permissions" do
    topic = topics(:direct_topic)
    admin = users(:guest_admin_normal)
    poll = PollService.create(params: poll_params(topic_id: topic.id), actor: admin)
    comment = CommentService.create(comment: Comment.new(parent: topic.discussion, body: "Direct"), actor: admin)
    records = {
      topic => %i[show update move pin close reopen discard update_tags announce members_autocomplete add_members add_guests],
      topic.discussion => %i[show update announce destroy],
      comment => %i[show update discard destroy],
      poll => %i[show export update announce remind add_voters close destroy],
      topic_readers(:direct_guest_normal_reader) => %i[update make_admin remove_admin resend remove]
    }
    actors = %i[guest_admin_normal guest_normal guest_loud non_guest_loud former_guest_loud inactive_guest_loud].map { |role| users(role) }
    permissions = actors.flat_map do |actor|
      records.flat_map { |record, actions| actions.map { |action| [actor, record, action, actor.can?(action, record)] } }
    end
    assert admin.can?(:announce, poll)
    groups(:group).discard!
    permissions.each do |actor, record, action, allowed|
      assert_equal allowed, actor.can?(action, record), "#{actor.id}: #{action} #{record.class}"
    end
  end

  test "discarded relationships no longer grant contact permission while direct relationships still do" do
    member = users(:member_normal)
    other_member = users(:member_loud)
    guest = users(:guest_normal)
    direct_guest = users(:guest_loud)
    assert member.can?(:contact, other_member)
    assert guest.can?(:contact, direct_guest)
    groups(:group).discard!
    member.reload
    other_member.reload
    assert_not member.can?(:contact, other_member)
    assert guest.can?(:contact, direct_guest)
  end

  test "discarded voter invitations cannot be redeemed" do
    poll = PollService.create(params: poll_params(topic_id: topics(:discussion_topic).id), actor: users(:admin))
    stance = poll.stances.latest.find_by!(participant: users(:guest_normal))
    stance.update!(inviter: users(:admin), accepted_at: nil)
    assert Stance.redeemable.exists?(stance.id)
    groups(:group).discard!
    assert_not Stance.redeemable.exists?(stance.id)
    StanceService.redeem(stance: stance, actor: stance.participant)
    assert_nil stance.reload.accepted_at
  end

  private

  def poll_params(**attributes)
    {title: "Archive permissions", poll_type: "proposal", poll_option_names: %w[Yes No],
     closing_at: 1.day.from_now}.merge(attributes)
  end
end
