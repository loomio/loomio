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
    @subgroup_member = new_user("subgroup_member")
    @other_member = new_user("other_member")
    @guest = new_user("guest")
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

    @discussion = DiscussionService.build(params: { title: "Disc #{hex}", private: true, description_format: "html" }, actor: @actor)
    @discussion.save(validate: false)
    @discussion.create_missing_created_event!

    @group.add_member!(@actor)
    @group.add_member!(@member)
    @subgroup.add_member!(@actor)
    @subgroup.add_member!(@subgroup_member)
    @other_group.add_member!(@actor)
    @other_group.add_member!(@other_member)

    @discussion.topic.topic_readers.create!(user_id: @actor.id, inviter_id: @actor.id)
    @discussion.topic.topic_readers.create!(user_id: @guest.id, guest: true, inviter_id: @actor.id)

    ActionMailer::Base.deliveries.clear
  end

  # -- nil model --

  test "nil model returns members of actors groups and actors guests" do
    names = UserQuery.invitable_search(model: nil, actor: @actor).pluck(:name)
    [@member, @subgroup_member, @other_member, @guest].each do |u|
      assert_includes names, u.name
    end
    refute_includes names, @unrelated.name
  end

  # -- topic without group, as topic admin --

  test "topic without group as admin returns actors group members and topic guests" do
    @discussion.topic.topic_readers.where(user_id: @actor.id).update_all(admin: true, guest: true)

    names = UserQuery.invitable_search(model: @discussion, actor: @actor).pluck(:name)
    [@member, @subgroup_member, @other_member, @guest].each do |u|
      assert_includes names, u.name
    end
    refute_includes names, @unrelated.name
  end

  # -- topic without group, as topic member (not admin) --

  test "topic without group as member returns only topic readers" do
    @discussion.topic.topic_readers.where(user_id: @actor.id).update_all(guest: true)

    names = UserQuery.invitable_search(model: @discussion, actor: @actor).pluck(:name)
    assert_includes names, @guest.name
    assert_includes names, @actor.name
    assert_equal 2, names.count
  end

  # -- topic without group, not a topic member --

  test "topic without group as non-member returns nothing" do
    names = UserQuery.invitable_search(model: @discussion, actor: @actor).pluck(:name)
    assert_equal 0, names.count
  end

  # -- topic in group, as group admin --

  test "topic in group as group admin returns group and subgroup members and topic guests" do
    @discussion.topic.update!(group_id: @group.id)
    Membership.where(user: @actor, group: @group).update(admin: true)

    names = UserQuery.invitable_search(model: @discussion, actor: @actor).pluck(:name)
    [@member, @subgroup_member, @guest].each do |u|
      assert_includes names, u.name
    end
    [@other_member, @unrelated].each do |u|
      refute_includes names, u.name
    end
  end

  # -- topic in group, as member, members_can_add_guests=true --

  test "topic in group as member with guests allowed returns group and subgroup members and guests" do
    @discussion.topic.update!(group_id: @group.id)
    Membership.where(user: @actor, group: @group).update(admin: false)
    @group.update(members_can_add_guests: true)

    names = UserQuery.invitable_search(model: @discussion, actor: @actor).pluck(:name)
    [@member, @subgroup_member, @guest].each do |u|
      assert_includes names, u.name
    end
    [@other_member, @unrelated].each do |u|
      refute_includes names, u.name
    end
  end

  # -- topic in group, as member, members_can_add_guests=false --

  test "topic in group as member without guest permission returns group members and topic guests" do
    @discussion.topic.update!(group_id: @group.id)
    Membership.where(user: @actor, group: @group).update(admin: false)
    @discussion.topic.group.update_column(:members_can_add_guests, false)

    names = UserQuery.invitable_search(model: @discussion, actor: @actor).pluck(:name)
    [@member, @guest].each do |u|
      assert_includes names, u.name
    end
    [@subgroup_member, @other_member, @unrelated].each do |u|
      refute_includes names, u.name
    end
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
