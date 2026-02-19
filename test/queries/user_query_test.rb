require 'test_helper'

class UserQueryTest < ActiveSupport::TestCase
  setup do
    hex = SecureRandom.hex(4)

    def new_user(name)
      h = SecureRandom.hex(4)
      User.create!(name: name, email: "#{name.parameterize}#{h}@example.com", username: "#{name.parameterize.gsub(/[^a-z0-9]/, '')}#{h}", email_verified: true)
    end

    @actor = new_user("actor")
    @member = new_user("member")
    @other_member = new_user("other_member")
    @subgroup_member = new_user("subgroup_member")
    @thread_guest = new_user("thread_guest")
    @other_guest = new_user("other_guest")
    @poll_guest = new_user("poll_guest")
    @unrelated = new_user("unrelated")

    @group = Group.new(name: "group#{hex}", group_privacy: 'closed', discussion_privacy_options: 'public_or_private', members_can_add_members: true)
    @group.save(validate: false)
    @group.subscription = Subscription.create!(plan: 'trial', state: 'active')
    @group.save(validate: false)
    @subgroup = Group.new(name: "subgroup#{hex}", parent: @group, group_privacy: 'closed', discussion_privacy_options: 'public_or_private')
    @subgroup.save(validate: false)
    @other_group = Group.new(name: "othergroup#{hex}", group_privacy: 'closed', discussion_privacy_options: 'public_or_private', members_can_add_members: true)
    @other_group.save(validate: false)
    @other_group.subscription = Subscription.create!(plan: 'trial', state: 'active')
    @other_group.save(validate: false)

    @discussion = Discussion.new(title: "Disc #{hex}", author: @actor, description_format: "html", private: true)
    @discussion.save(validate: false)
    @discussion.create_missing_created_event!
    @other_discussion = Discussion.new(title: "Other disc #{hex}", author: @actor, description_format: "html", private: true)
    @other_discussion.save(validate: false)
    @other_discussion.create_missing_created_event!

    @poll_author = new_user("pollauthor")
    @poll = Poll.new(poll_type: "poll", title: "Poll #{hex}", author: @poll_author, poll_option_names: ["engage"], closing_at: 5.days.from_now, opened_at: Time.now, notify_on_closing_soon: "voters")
    @poll.save!
    @poll.create_missing_created_event!
    @other_poll = Poll.new(poll_type: "poll", title: "Other poll #{hex}", author: @poll_author, poll_option_names: ["engage"], closing_at: 5.days.from_now, opened_at: Time.now, notify_on_closing_soon: "voters")
    @other_poll.save!
    @other_poll.create_missing_created_event!

    @group.add_member!(@actor)
    @group.add_member!(@member)
    @subgroup.add_member!(@actor)
    @subgroup.add_member!(@subgroup_member)
    @other_group.add_member!(@actor)
    @other_group.add_member!(@other_member)

    @discussion.topic.topic_readers.create!(user_id: @actor.id, inviter_id: @actor.id)
    @discussion.topic.topic_readers.create!(user_id: @thread_guest.id, guest: true, inviter_id: @actor.id)
    @other_discussion.topic.topic_readers.create!(user_id: @actor.id, inviter_id: @actor.id)
    @other_discussion.topic.topic_readers.create!(user_id: @other_guest.id, guest: true, inviter_id: @actor.id)

    @poll.stances.create!(participant_id: @actor.id, inviter_id: @actor.id)
    @poll.stances.create!(participant_id: @poll_guest.id, inviter: @actor)
    @poll.add_guest!(@poll_guest, @actor)

    ActionMailer::Base.deliveries.clear
  end

  # -- nil model --

  test "nil model returns members of actors groups and actors guests" do
    names = UserQuery.invitable_search(model: nil, actor: @actor).pluck(:name)
    [@member, @subgroup_member, @other_member, @poll_guest, @thread_guest].each do |u|
      assert_includes names, u.name
    end
  end

  # -- discussion without group, as admin --

  test "discussion without group as admin returns actors group members and previous guests" do
    @poll.update(discussion: @discussion)
    @discussion.topic.topic_readers.where(user_id: @actor.id).update_all(admin: true, guest: true)

    names = UserQuery.invitable_search(model: @discussion, actor: @actor).pluck(:name)
    [@member, @subgroup_member, @other_member, @thread_guest, @poll_guest].each do |u|
      assert_includes names, u.name
    end
    refute_includes names, @unrelated.name
  end

  # -- discussion without group, as member --

  test "discussion without group as member returns only thread and poll guests" do
    @poll.update(discussion: @discussion)
    @discussion.topic.topic_readers.where(user_id: @actor.id).update_all(guest: true)

    names = UserQuery.invitable_search(model: @discussion, actor: @actor).pluck(:name)
    [@thread_guest, @poll_guest, @actor].each do |u|
      assert_includes names, u.name
    end
    assert_equal 3, names.count
  end

  # -- discussion in group, as group admin --

  test "discussion in group as admin returns group and subgroup members and guests" do
    @poll.update(discussion: @discussion)
    @discussion.update(group_id: @group.id)
    Membership.where(user: @actor, group: @group).update(admin: true)

    names = UserQuery.invitable_search(model: @discussion, actor: @actor).pluck(:name)
    [@member, @subgroup_member, @thread_guest, @poll_guest].each do |u|
      assert_includes names, u.name
    end
  end

  test "discussion in group as admin excludes other org members and unrelated users" do
    @poll.update(discussion: @discussion)
    @discussion.update(group_id: @group.id)
    Membership.where(user: @actor, group: @group).update(admin: true)

    names = UserQuery.invitable_search(model: @discussion, actor: @actor).pluck(:name)
    [@other_member, @unrelated].each do |u|
      refute_includes names, u.name
    end
  end

  # -- discussion in group, as member, members_can_add_guests=true --

  test "discussion in group as member with guests allowed returns group and subgroup members" do
    @poll.update(discussion: @discussion)
    @discussion.update(group_id: @group.id)
    Membership.where(user: @actor, group: @group).update(admin: false)
    @group.update(members_can_add_guests: true)

    names = UserQuery.invitable_search(model: @discussion, actor: @actor).pluck(:name)
    [@member, @subgroup_member, @thread_guest, @poll_guest].each do |u|
      assert_includes names, u.name
    end
    [@other_member, @unrelated].each do |u|
      refute_includes names, u.name
    end
  end

  # -- discussion in group, as member, members_can_add_guests=false --

  test "discussion in group as member without guests returns group members and thread guests" do
    @poll.update(discussion: @discussion)
    @discussion.topic.update!(group_id: @group.id)
    @discussion.reload
    Membership.where(user: @actor, group: @group).update(admin: false)
    @discussion.group.update_column(:members_can_add_guests, false)

    names = UserQuery.invitable_search(model: @discussion, actor: @actor).pluck(:name)
    [@member, @thread_guest, @poll_guest].each do |u|
      assert_includes names, u.name
    end
    [@subgroup_member, @other_member, @unrelated].each do |u|
      refute_includes names, u.name
    end
  end

  # -- poll without group or discussion, as admin --

  test "poll without group as admin returns actors group members and poll guests" do
    @poll.stances.where(participant_id: @actor.id).update_all(inviter_id: @actor.id)
    @poll.topic.topic_readers.find_or_create_by!(user: @actor).update!(admin: true, guest: true)

    names = UserQuery.invitable_search(model: @poll, actor: @actor).pluck(:name)
    [@member, @subgroup_member, @other_member, @poll_guest].each do |u|
      assert_includes names, u.name
    end
    refute_includes names, @unrelated.name
  end

  # -- poll without group or discussion, as member --

  test "poll without group as member cannot invite" do
    names = UserQuery.invitable_search(model: @poll, actor: @actor).pluck(:name)
    assert_equal 0, names.size
  end

  # -- poll in discussion without group, as discussion admin --

  test "poll in discussion without group as discussion admin returns all guests" do
    @poll.update(discussion_id: @discussion.id, group_id: nil)
    @discussion.topic.topic_readers.where(user_id: @actor.id).update_all(admin: true, guest: true)

    names = UserQuery.invitable_search(model: @poll, actor: @actor).pluck(:name)
    [@member, @subgroup_member, @other_member, @poll_guest, @thread_guest].each do |u|
      assert_includes names, u.name
    end
    refute_includes names, @unrelated.name
  end

  # -- poll in discussion without group, as discussion member --

  test "poll in discussion without group as discussion member cannot invite" do
    @poll.update(discussion_id: @discussion.id, group_id: nil)
    @discussion.topic.topic_readers.where(user_id: @actor.id).update_all(admin: false)

    names = UserQuery.invitable_search(model: @poll, actor: @actor).pluck(:name)
    refute_includes names, @poll_guest.name
    refute_includes names, @thread_guest.name
    refute_includes names, @actor.name
    assert_equal 0, names.count
  end

  # -- poll in group, as group admin --

  test "poll in group as admin returns group and subgroup members and poll guests" do
    @poll.update(group: @group)
    Membership.where(user: @actor, group: @group).update(admin: true)

    names = UserQuery.invitable_search(model: @poll, actor: @actor).pluck(:name)
    [@member, @subgroup_member, @poll_guest].each do |u|
      assert_includes names, u.name
    end
    [@other_member, @unrelated].each do |u|
      refute_includes names, u.name
    end
  end

  # -- poll in group, as member + poll admin, guests allowed --

  test "poll in group as member topic admin with guests allowed returns group and subgroup" do
    @poll.update(group: @group)
    Membership.where(user: @actor, group: @group).update(admin: false)
    @poll.topic.topic_readers.find_or_create_by!(user: @actor).update!(admin: true)
    @group.update(members_can_add_guests: true)

    names = UserQuery.invitable_search(model: @poll, actor: @actor).pluck(:name)
    [@member, @subgroup_member, @poll_guest].each do |u|
      assert_includes names, u.name
    end
    [@other_member, @unrelated].each do |u|
      refute_includes names, u.name
    end
  end

  # -- poll in group, as member + poll admin, guests not allowed --

  test "poll in group as member topic admin without guests returns group members and poll guest" do
    @poll.update(group: @group)
    Membership.where(user: @actor, group: @group).update(admin: false)
    @poll.topic.topic_readers.find_or_create_by!(user: @actor).update!(admin: true)
    @group.update_column(:members_can_add_guests, false)

    names = UserQuery.invitable_search(model: @poll, actor: @actor).pluck(:name)
    [@member, @poll_guest, @actor].each do |u|
      assert_includes names, u.name
    end
    assert_equal 3, names.size
    [@other_member, @thread_guest, @unrelated].each do |u|
      refute_includes names, u.name
    end
  end

  # -- poll in group, as member (not poll admin), various guest settings --

  test "poll in group as member with guests allowed and specified_voters_only returns nobody" do
    @poll.update(group: @group, specified_voters_only: true)
    Membership.where(user: @actor, group: @group).update(admin: false)
    @poll.group.update(members_can_add_guests: true)

    names = UserQuery.invitable_search(model: @poll, actor: @actor).pluck(:name)
    assert_equal 0, names.size
  end

  test "poll in group as member with guests allowed and specified_voters_only false returns nobody" do
    @poll.update(group: @group, specified_voters_only: false)
    Membership.where(user: @actor, group: @group).update(admin: false)
    @poll.group.update(members_can_add_guests: true)

    names = UserQuery.invitable_search(model: @poll, actor: @actor).pluck(:name)
    assert_equal 0, names.size
  end

  test "poll in group as member without guests and specified_voters_only returns nobody" do
    @poll.update(group: @group, specified_voters_only: true)
    Membership.where(user: @actor, group: @group).update(admin: false)
    @poll.group.update_column(:members_can_add_guests, false)

    names = UserQuery.invitable_search(model: @poll, actor: @actor).pluck(:name)
    assert_equal 0, names.size
  end

  test "poll in group as member without guests and specified_voters_only false returns nobody" do
    @poll.update(group: @group, specified_voters_only: false)
    Membership.where(user: @actor, group: @group).update(admin: false)
    @poll.group.update_column(:members_can_add_guests, false)

    names = UserQuery.invitable_search(model: @poll, actor: @actor).pluck(:name)
    assert_equal 0, names.size
  end

  # -- group --

  test "inviting to group shows subgroup members" do
    Membership.where(user: @actor, group: @group).update(admin: true)
    names = UserQuery.invitable_search(model: @group, actor: @actor).pluck(:name)
    assert_includes names, @subgroup_member.name
  end

  test "inviting to subgroup shows parent members" do
    Membership.where(user: @actor, group: @subgroup).update(admin: true)
    names = UserQuery.invitable_search(model: @subgroup, actor: @actor).pluck(:name)
    assert_includes names, @member.name
  end
end
