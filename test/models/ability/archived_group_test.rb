require "test_helper"

class Ability::ArchivedGroupTest < ActiveSupport::TestCase
  test "archival denies new content and voting across the access matrix" do
    topic = topics(:discussion_topic)
    poll = PollService.create(params: poll_params(topic_id: topic.id), actor: users(:admin))
    roles = %i[admin user member_normal guest_normal guest_admin_normal alien_loud
               non_guest_loud former_member_loud former_guest_loud inactive_member_loud inactive_guest_loud]
    assert users(:member_normal).can?(:create, Comment.new(parent: topic.discussion))
    assert users(:guest_normal).can?(:vote_in, poll)

    groups(:group).archive!
    topic.reload
    poll.reload
    actors = roles.map { |role| users(role) } + [LoggedOutUser.new]
    actors.each do |actor|
      assert_not actor.can?(:create, Comment.new(parent: topic.discussion)), actor.inspect
      assert_not actor.can?(:create, DiscussionService.build(params: {title: "Archived", group_id: topic.group_id}, actor: users(:admin)))
      assert_not actor.can?(:create, PollService.build(params: poll_params(topic_id: topic.id), actor: users(:admin)))
      Poll.hide_results.keys.each do |mode|
        poll.assign_attributes(hide_results: mode, quorum_pct: 50)
        assert_not actor.can?(:vote_in, poll)
      end
    end
  end

  test "archived content creation services reject requests without writing records" do
    topic = topics(:discussion_topic)
    poll = PollService.create(params: poll_params(topic_id: topic.id), actor: users(:admin))
    groups(:group).archive!
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

  test "public groups and inherited subgroup archival block new activity" do
    %i[public_discussion_topic subgroup_discussion_topic].each do |name|
      topic = topics(name)
      actor = topic.discussion.author
      topic.group.add_admin!(actor)
      assert actor.can?(:create, Comment.new(parent: topic.discussion))
      (name == :subgroup_discussion_topic ? groups(:group) : topic.group).archive!
      topic.reload
      assert_not actor.can?(:create, Comment.new(parent: topic.discussion))
      assert_not actor.can?(:create, DiscussionService.build(params: {title: "Archived", group_id: topic.group_id}, actor: actor))
    end
  end

  test "direct topics retain member access and reject nonmembers after a group is archived" do
    groups(:group).archive!
    topic = topics(:direct_topic)
    actor = users(:guest_admin_normal)
    comment = CommentService.create(comment: Comment.new(parent: topic.discussion, body: "Direct comment"), actor: actor)
    assert comment.persisted?
    poll = PollService.create(params: poll_params(topic_id: topic.id), actor: actor)
    assert poll.persisted?
    assert_nil topic.group.archived_at
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
    assert_nil discussion.group.archived_at
    poll.update!(closed_at: Time.current)
    assert_not actor.can?(:vote_in, poll)
  end

  test "archival suspends content management and invitations while retaining cleanup" do
    topic = topics(:discussion_topic)
    admin = users(:admin)
    poll = PollService.create(params: poll_params(topic_id: topic.id), actor: admin)
    comment = CommentService.create(comment: Comment.new(parent: topic.discussion, body: "Before archival"), actor: admin)
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
    group.archive!
    records.each_key { |record| record.reload if record.persisted? }
    # Unsaved records can still hold their group's pre-archive association.
    records.each_key { |record| record.group.reload if record.respond_to?(:group) && record.group.present? }

    [admin, users(:member_normal), users(:guest_admin_normal), LoggedOutUser.new].each do |actor|
      records.each do |record, actions|
        actions.each { |action| assert_not actor.can?(action, record), "#{actor.id}: #{action} #{record.class}" }
      end
      %i[update email_members view_pending_invitations members_autocomplete show_chatbots
         move_discussions_to add_guests add_members invite_people announce manage_membership_requests
         notify add_subgroup move merge].each do |action|
        assert_not actor.can?(action, group), action
      end
      assert_not actor.can?(:create, Group.new(parent: group))
    end

    %i[archive publish export destroy].each { |action| assert admin.can?(action, group), action }
    %i[remove_admin revoke destroy remove_delegate].each { |action| assert admin.can?(action, membership), action }
    assert membership.user.can?(:update, membership)
    assert_not admin.can?(:update, membership)
    assert admin.can?(:remove, reader)
    assert admin.can?(:remove_admin, reader)
    assert reader.user.can?(:update, reader)
    assert admin.can?(:destroy, Chatbot.new(group: group))
    assert_not users(:member_normal).can?(:export, group)
  end

  test "archiving an unrelated group preserves all existing direct topic management permissions" do
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
    groups(:group).archive!
    permissions.each do |actor, record, action, allowed|
      assert_equal allowed, actor.can?(action, record), "#{actor.id}: #{action} #{record.class}"
    end
  end

  test "archived relationships no longer grant contact permission while direct relationships still do" do
    member = users(:member_normal)
    other_member = users(:member_loud)
    guest = users(:guest_normal)
    direct_guest = users(:guest_loud)
    assert member.can?(:contact, other_member)
    assert guest.can?(:contact, direct_guest)
    groups(:group).archive!
    member.reload
    other_member.reload
    assert_not member.can?(:contact, other_member)
    assert guest.can?(:contact, direct_guest)
  end

  test "archived voter invitations cannot be redeemed" do
    poll = PollService.create(params: poll_params(topic_id: topics(:discussion_topic).id), actor: users(:admin))
    stance = poll.stances.latest.find_by!(participant: users(:guest_normal))
    stance.update!(inviter: users(:admin), accepted_at: nil)
    assert Stance.redeemable.exists?(stance.id)
    groups(:group).archive!
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
