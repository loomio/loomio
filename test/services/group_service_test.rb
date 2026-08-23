require 'test_helper'

class GroupServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
  end

  test "creates a new group" do
    group = Group.new(
      name: 'New Group',
      handle: "newgroup-#{SecureRandom.hex(4)}"
    )

    assert_difference 'Group.count', 1 do
      GroupService.create(group: group, actor: @user)
    end

    assert_equal @user, group.reload.creator
  end

  test "publishes a public subgroup to parent group members" do
    parent = create_parent_group(group_privacy: 'closed')
    subgroup = Group.new(
      name: "Public subgroup #{SecureRandom.hex(4)}",
      parent: parent,
      group_privacy: 'closed'
    )

    assert_subgroup_published_to_parent(subgroup, parent)
  end

  test "publishes a parent-visible subgroup to parent group members" do
    parent = create_parent_group(group_privacy: 'secret')
    subgroup = Group.new(
      name: "Parent-visible subgroup #{SecureRandom.hex(4)}",
      parent: parent,
      group_privacy: 'closed'
    )

    assert subgroup.is_visible_to_parent_members?
    assert_subgroup_published_to_parent(subgroup, parent)
  end

  test "does not publish a secret subgroup to parent group members" do
    parent = create_parent_group(group_privacy: 'secret')
    subgroup = Group.new(
      name: "Secret subgroup #{SecureRandom.hex(4)}",
      parent: parent,
      group_privacy: 'secret'
    )
    publications = capture_group_publications do
      GroupService.create(group: subgroup, actor: @user)
    end

    refute publications.any? { |models, options| models == [subgroup] && options[:group_id] == parent.id }
  end

  test "exports open and closed subgroups for a parent group admin" do
    parent = create_parent_group(group_privacy: 'secret')
    closed_subgroup = create_subgroup(parent: parent, group_privacy: 'closed')
    open_subgroup = create_subgroup(parent: parent, group_privacy: 'open')
    secret_subgroup = create_subgroup(parent: parent, group_privacy: 'secret')
    joined_secret_subgroup = create_subgroup(parent: parent, group_privacy: 'secret')
    joined_secret_subgroup.add_member!(@user, inviter: joined_secret_subgroup.creator)

    group_ids = capture_group_export_ids(parent, @user)

    assert_includes group_ids, parent.id
    assert_includes group_ids, closed_subgroup.id
    assert_includes group_ids, open_subgroup.id
    assert_includes group_ids, joined_secret_subgroup.id
    refute_includes group_ids, secret_subgroup.id
  end

  test "only group admins can export a group" do
    parent = create_parent_group(group_privacy: 'secret')
    member = users(:member)
    parent.add_member!(member, inviter: @user)

    assert_raises CanCan::AccessDenied do
      GroupService.export(group: parent, actor: member)
    end
  end

  test "does not reparent a group on update" do
    group = Group.create!(
      name: "Managed Group",
      handle: "managed-#{SecureRandom.hex(4)}"
    )
    group.add_admin!(@user)
    parent = Group.create!(
      name: "Unexpected Parent",
      handle: "unexpected-parent-#{SecureRandom.hex(4)}"
    )
    parent.add_admin!(@user)

    GroupService.update(group: group, params: { parent_id: parent.id, name: "Still Managed" }, actor: @user)

    assert_equal "Still Managed", group.reload.name
    assert_nil group.parent_id
  end

  test "invites a user by email" do
    group = Group.create!(
      name: 'Invite Group',
      handle: "invitegroup-#{SecureRandom.hex(4)}"
    )
    group.add_admin!(@user)

    subscription = Subscription.create(max_members: nil)
    group.update!(subscription: subscription)

    initial_count = group.memberships.count

    GroupService.invite(
      group: group,
      actor: group.creator,
      params: { recipient_emails: ['test@example.com'] }
    )

    assert_equal initial_count + 1, group.memberships.count
  end

  test "inviting a user creates direct deliveries without an topic_item" do
    group = Group.create!(
      name: "Direct notification invitations",
      handle: "direct-notification-invitations-#{SecureRandom.hex(4)}",
      creator: @user
    )
    group.add_admin!(@user)
    email = "direct-invite-#{SecureRandom.hex(4)}@example.com"

    assert_no_difference -> { TopicItem.where(kind: "membership_created").count } do
      GroupService.invite(
        group: group,
        actor: @user,
        params: { recipient_emails: [ email ], recipient_message: "Welcome" }
      )
    end

    recipient = User.find_by!(email: email)
    notification = Notification.find_by!(
      kind: "membership_created",
      subject: group
    )
    ResolveNotificationDeliveriesWorker.perform_now(notification.id)

    assert_equal "Welcome", notification.recipient_message
    assert_equal [ recipient.id ], notification.recipient_user_ids
    assert_equal %w[email in_app], notification.notification_deliveries.order(:channel).pluck(:channel)

    delivery = notification.notification_deliveries.find_by!(channel: "email")
    assert_difference "ActionMailer::Base.deliveries.count", 1 do
      DeliverNotificationEmailWorker.perform_now(delivery.id)
    end
    assert_includes ActionMailer::Base.deliveries.last.to, email
  end

  test "rolls back invitations when notification creation fails" do
    group = Group.create!(
      name: 'Atomic invitations',
      handle: "atomic-invitations-#{SecureRandom.hex(4)}",
      creator: @user
    )
    group.add_admin!(@user)
    email = "atomic-invite-#{SecureRandom.hex(4)}@example.com"

    assert_raises RuntimeError do
      NotificationService.stub(:create!, ->(**) { raise "notification failed" }) do
        GroupService.invite(group: group, actor: @user, params: { recipient_emails: [email] })
      end
    end

    invited_user = User.find_by(email: email)
    assert_nil invited_user
    assert_not Membership.joins(:user).exists?(group: group, users: { email: email })
  end

  test "does not mark membership as accepted if user doesnt belong to group already" do
    new_user = User.create!(
      name: 'Jim',
      email: 'jim@example.com',
      email_verified: true,
      username: 'jim'
    )

    group = Group.create!(
      name: 'Parent Group',
      handle: "parent-#{SecureRandom.hex(4)}"
    )
    group.add_admin!(@user)

    subscription = Subscription.create(max_members: nil)
    group.update!(subscription: subscription)

    GroupService.invite(
      group: group,
      actor: group.creator,
      params: { recipient_emails: [new_user.email] }
    )

    membership = Membership.find_by(user_id: new_user.id, group_id: group.id)
    assert_nil membership.accepted_at
  end

  test "marks membership as accepted if user already belongs to parent group" do
    parent = Group.create!(
      name: 'Parent Group',
      handle: "parent2-#{SecureRandom.hex(4)}",
      creator: @user
    )
    parent.add_admin!(@user)

    subgroup = Group.create!(
      name: 'Subgroup',
      parent: parent,
      handle: "#{parent.handle}-subgroup",
      creator: @user
    )
    subgroup.add_admin!(@user)

    alien = users(:alien)
    parent.add_member!(alien, inviter: parent.creator)

    GroupService.invite(
      group: subgroup,
      actor: @user,
      params: { recipient_emails: [alien.email] }
    )

    membership = Membership.find_by(user_id: alien.id, group_id: subgroup.id)
    assert_not_nil membership.accepted_at
  end

  test "restricts group to subscription max_members" do
    group = Group.create!(
      name: 'Limited Group',
      handle: "limited-#{SecureRandom.hex(4)}"
    )
    group.add_admin!(@user)

    subscription = Subscription.create(max_members: 1)
    group.update!(subscription: subscription)

    initial_count = group.memberships.count

    assert_raises Subscription::MaxMembersExceeded do
      GroupService.invite(
        group: group,
        actor: group.creator,
        params: { recipient_emails: ['test@example.com'] }
      )
    end

    assert_equal initial_count, group.memberships.count
  end

  test "moves a group to a parent as an admin" do
    admin_user = User.create!(
      name: 'Admin',
      email: "admin-#{SecureRandom.hex(4)}@example.com",
      email_verified: true,
      username: "adminuser#{SecureRandom.hex(4)}",
      is_admin: true
    )

    group = Group.create!(
      name: 'Movable Group',
      handle: "movable-#{SecureRandom.hex(4)}",
      subscription_id: 100
    )

    parent = Group.create!(
      name: 'Parent Group',
      handle: "newparent-#{SecureRandom.hex(4)}"
    )

    GroupService.move(group: group, parent: parent, actor: admin_user)

    assert_equal parent, group.reload.parent
    assert_nil group.subscription_id
    assert_includes parent.reload.subgroups, group
  end

  test "does not allow non-admins to move groups" do
    group = Group.create!(
      name: 'Movable Group',
      handle: "movable2-#{SecureRandom.hex(4)}",
      subscription_id: 100
    )

    parent = Group.create!(
      name: 'Parent Group',
      handle: "newparent2-#{SecureRandom.hex(4)}"
    )

    assert_raises CanCan::AccessDenied do
      GroupService.move(group: group, parent: parent, actor: @user)
    end
  end

  private

  def create_parent_group(group_privacy:)
    Group.create!(
      name: "Parent group #{SecureRandom.hex(4)}",
      group_privacy: group_privacy
    ).tap { |group| group.add_admin!(@user) }
  end

  def create_subgroup(parent:, group_privacy:)
    Group.create!(
      name: "Subgroup #{SecureRandom.hex(4)}",
      parent: parent,
      group_privacy: group_privacy
    )
  end

  def capture_group_export_ids(group, actor)
    group_ids = nil
    perform_later = ->(ids, _name, _actor_id) { group_ids = ids }
    GroupExportWorker.stub(:perform_later, perform_later) do
      GroupService.export(group: group, actor: actor)
    end
    group_ids
  end

  def assert_subgroup_published_to_parent(subgroup, parent)
    publications = capture_group_publications do
      GroupService.create(group: subgroup, actor: @user)
    end

    assert publications.any? { |models, options| models == [subgroup] && options[:group_id] == parent.id }
  end

  def capture_group_publications(&block)
    publications = []
    publish = ->(models, **options) { publications << [models, options] }
    MessageChannelService.stub(:publish_models, publish, &block)
    publications
  end
end
