require 'test_helper'

class PollServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @admin = users(:admin)
    @group = groups(:group)
  end

  # -- create_stances --
  # Note: Use specified_voters_only polls so auto-creation doesn't preempt create_stances

  test "creates stance by user id" do
    poll = create_poll(specified_voters_only: true)
    member = create_unique_user("stancemember")
    @group.add_member!(member)

    assert_equal 0, Stance.where(participant_id: member.id, poll: poll).where(revoked_at: nil).count
    PollService.create_stances(poll: poll, actor: @user, user_ids: [member.id])
    assert_equal 1, Stance.where(participant_id: member.id, poll: poll).where(revoked_at: nil).count
  end

  test "creates stance by email" do
    poll = create_poll(specified_voters_only: true)
    member = create_unique_user("stanceemail")
    @group.add_member!(member)

    PollService.create_stances(poll: poll, actor: @user, emails: [member.email])
    assert_equal 1, Stance.where(participant_id: member.id, poll: poll).where(revoked_at: nil).count
  end

  test "creates stance by audience" do
    poll = create_poll(specified_voters_only: true)
    member = create_unique_user("stanceaudience")
    @group.add_member!(member)

    PollService.create_stances(poll: poll, actor: @user, audience: 'group')
    assert_equal 1, Stance.where(participant_id: member.id, poll: poll).where(revoked_at: nil).count
  end

  test "only creates stances once per user" do
    poll = create_poll(specified_voters_only: true)
    member = create_unique_user("stanceonce")
    @group.add_member!(member)

    PollService.create_stances(poll: poll, actor: @user, user_ids: [member.id])
    count = Stance.where(participant_id: member.id, poll: poll).where(revoked_at: nil).count
    assert_equal 1, count
    PollService.create_stances(poll: poll, actor: @user, user_ids: [member.id])
    assert_equal count, Stance.where(participant_id: member.id, poll: poll).where(revoked_at: nil).count
    PollService.create_stances(poll: poll, actor: @user, emails: [member.email])
    assert_equal count, Stance.where(participant_id: member.id, poll: poll).where(revoked_at: nil).count
  end

  test "creates stances for specified voters" do
    poll = create_poll(specified_voters_only: true)
    member = create_unique_user("voldefault")
    @group.add_member!(member)

    PollService.create_stances(poll: poll, actor: @user, user_ids: [member.id])
    assert Stance.where(participant_id: member.id, poll: poll).exists?
  end

  # -- create --

  test "creates a new poll" do
    assert_difference 'Poll.count', 1 do
      PollService.create(params: poll_params, actor: @user)
    end
  end

  test "populates custom poll options" do
    poll = PollService.create(params: poll_params(
      poll_type: "poll",
      poll_option_names: ["green"]
    ), actor: @user)
    assert_equal 1, poll.reload.poll_options.count
    assert_equal "green", poll.poll_options.first.name
  end

  test "does not create an invalid poll" do
    assert_no_difference 'Poll.count' do
      assert_raises ActiveRecord::RecordInvalid do
        PollService.create(params: poll_params(title: ""), actor: @user)
      end
    end
  end

  test "does not allow unauthorized users to create polls" do
    outsider = create_unique_user("pollunauthorized")
    assert_raises CanCan::AccessDenied do
      PollService.create(params: poll_params, actor: outsider)
    end
  end

  test "poll_created publishes poll_announced when notify_on_open is true" do
    poll = PollService.create(params: poll_params(notify_on_open: true), actor: @user)
    assert poll.opened?
    assert Event.where(kind: 'poll_announced', eventable: poll).exists?
  end

  test "poll_created does not publish poll_announced when notify_on_open is false" do
    poll = PollService.create(params: poll_params(notify_on_open: false), actor: @user)
    assert poll.opened?
    refute Event.where(kind: 'poll_announced', eventable: poll).exists?
  end

  test "publish_topic_if_active excludes group records from topic broadcasts" do
    poll = create_poll
    calls = []

    MessageChannelService.stub(:publish_models, ->(models, **options) { calls << [models, options] }) do
      PollService.publish_topic_if_active(poll)
    end

    cache = RecordCache.for_collection([poll.topic], nil, ['group'])

    assert_not_empty calls
    assert calls.all? { |models, _options| models == [poll.topic] }
    assert calls.all? { |_models, options| options[:scope] == {exclude_types: ['group']} }
    assert_nil cache.scope[:groups_by_id]
    assert_nil cache.scope[:subscriptions_by_group_id]
  end

  # Note: poll mention notification test omitted due to asset pipeline dependency
  # (poll_mailer/vote-button-.png). Mention notifications are covered in discussion_service_test.

  # -- update --

  test "updates an existing poll" do
    poll = create_poll
    PollService.update(poll: poll, params: { details: "A new description" }, actor: @user)
    assert_equal "A new description", poll.reload.details
  end

  test "does not allow unauthorized users to update polls" do
    poll = create_poll
    outsider = create_unique_user("pollupdate")
    assert_raises CanCan::AccessDenied do
      PollService.update(poll: poll, params: { details: "Hacked" }, actor: outsider)
    end
    assert_not_equal "Hacked", poll.reload.details
  end

  test "does not save an invalid poll on update" do
    poll = create_poll
    old_title = poll.title
    PollService.update(poll: poll, params: { title: "" }, actor: @user)
    assert_equal old_title, poll.reload.title
  end

  test "creates poll edited event for title change" do
    poll = create_poll
    assert_difference "Events::PollEdited.where(kind: :poll_edited).count", 1 do
      PollService.update(poll: poll, params: { title: "BIG CHANGES!" }, actor: @user)
    end
  end

  test "creates poll edited event for poll option changes" do
    poll = create_poll
    assert_difference "Events::PollEdited.where(kind: :poll_edited).count", 1 do
      PollService.update(poll: poll, params: { poll_option_names: ["new_option"] }, actor: @user)
    end
  end

  # -- close --

  test "closes a poll" do
    poll = create_poll
    PollService.close(poll: poll, actor: @user)
    assert_not_nil poll.reload.closed_at
  end

  test "does not allow change from anonymous to normal" do
    poll = create_poll
    poll.update!(anonymous: true)
    poll.anonymous = false
    assert_not poll.save
  end

  test "does not allow hiding results change after creation" do
    poll = create_poll
    poll.update!(hide_results: :until_closed)
    poll.hide_results = :off
    assert_not poll.save
  end

  test "disallows new stances after close" do
    poll = create_poll
    stance = Stance.new(poll: poll)
    assert @user.ability.can?(:create, stance)
    PollService.close(poll: poll, actor: @user)
    assert_not @user.ability.can?(:create, stance)
  end

  # -- expire_lapsed_polls --

  test "expires a lapsed poll" do
    poll = create_poll
    poll.update_attribute(:closing_at, 1.day.ago)
    PollService.expire_lapsed_polls
    assert_not_nil poll.reload.closed_at
  end

  test "does not expire active poll" do
    poll = create_poll
    PollService.expire_lapsed_polls
    assert_nil poll.reload.closed_at
  end

  test "does not touch already closed polls" do
    poll = create_poll
    poll.update!(closing_at: 1.day.ago, closed_at: 1.day.ago)
    original_closed_at = poll.reload.closed_at
    PollService.expire_lapsed_polls
    assert_equal original_closed_at, poll.reload.closed_at
  end

  # -- scheduled opening (opening_at) --

  test "scheduled poll is not opened at create time" do
    poll = PollService.create(params: poll_params(
      closing_at: 7.days.from_now,
      opening_at: 3.days.from_now,
      notify_on_open: true
    ), actor: @user)
    refute poll.opened?, "poll should not be opened when opening_at is in the future"
    refute Event.where(kind: 'poll_announced', eventable: poll).exists?,
      "no poll_announced event should be created for scheduled poll at create time"
  end

  test "open_scheduled_polls opens scheduled polls and sends poll_announced when notify_on_open is true" do
    poll = PollService.create(params: poll_params(
      closing_at: 7.days.from_now,
      opening_at: 3.days.from_now,
      notify_on_open: true
    ), actor: @user)
    refute poll.opened?

    poll.update_column(:opening_at, 1.minute.ago)

    PollService.open_scheduled_polls
    poll.reload
    assert poll.opened?, "poll should be opened after open_scheduled_polls runs"
    assert Event.where(kind: 'poll_announced', eventable: poll).exists?,
      "poll_announced event should be created when notify_on_open is true"
  end

  test "open_scheduled_polls opens scheduled polls without poll_announced when notify_on_open is false" do
    poll = PollService.create(params: poll_params(
      closing_at: 7.days.from_now,
      opening_at: 3.days.from_now,
      notify_on_open: false
    ), actor: @user)
    poll.update_column(:opening_at, 1.minute.ago)

    PollService.open_scheduled_polls
    poll.reload
    assert poll.opened?, "poll should be opened after open_scheduled_polls runs"
    refute Event.where(kind: 'poll_announced', eventable: poll).exists?,
      "no poll_announced event when notify_on_open is false"
  end

  test "open_scheduled_polls does not open polls whose opening_at is still in the future" do
    poll = PollService.create(params: poll_params(
      closing_at: 7.days.from_now,
      opening_at: 3.days.from_now,
      notify_on_open: true
    ), actor: @user)
    PollService.open_scheduled_polls
    poll.reload
    refute poll.opened?, "poll should not be opened when opening_at is still in the future"
  end

  # -- reopen --

  test "reopen sends poll_announced when notify_on_open is true" do
    poll = create_poll(notify_on_open: true)
    PollService.close(poll: poll, actor: @user)
    poll.reload

    announced_count_before = Event.where(kind: 'poll_announced', eventable: poll).count
    PollService.reopen(poll: poll, params: { closing_at: 7.days.from_now }, actor: @user)
    poll.reload

    assert poll.opened?, "poll should be opened after reopen"
    assert_nil poll.opening_at, "opening_at should be nil after reopen"
    assert_operator Event.where(kind: 'poll_announced', eventable: poll).count, :>, announced_count_before,
      "poll_announced event should be created on reopen with notify_on_open=true"
  end

  test "reopen does not send poll_announced when notify_on_open is false" do
    poll = create_poll(notify_on_open: false)
    PollService.close(poll: poll, actor: @user)
    poll.reload

    announced_count_before = Event.where(kind: 'poll_announced', eventable: poll).count
    PollService.reopen(poll: poll, params: { closing_at: 7.days.from_now }, actor: @user)
    poll.reload

    assert poll.opened?, "poll should be opened after reopen"
    assert_equal announced_count_before, Event.where(kind: 'poll_announced', eventable: poll).count,
      "no poll_announced event on reopen when notify_on_open is false"
  end

  # -- invite to scheduled poll --

  test "invite to scheduled poll creates stances but does not send poll_announced" do
    poll = PollService.create(params: poll_params(
      closing_at: 7.days.from_now,
      opening_at: 3.days.from_now,
      specified_voters_only: true,
      notify_on_open: true
    ), actor: @user)
    refute poll.opened?

    member = create_unique_user("scheduledinvite")
    Membership.create!(user: member, group: @group, accepted_at: Time.current)

    PollService.invite(poll: poll, actor: @user, params: {
      recipient_user_ids: [member.id],
      notify_recipients: false
    })

    assert Stance.where(participant_id: member.id, poll: poll).exists?,
      "stance should be created for invited user"
    refute Event.where(kind: 'poll_announced', eventable: poll).exists?,
      "no poll_announced when inviting to scheduled poll without notify_recipients"
  end

  # -- email delivery --

  test "open_scheduled_polls delivers emails to voters when notify_on_open is true" do
    member = create_unique_user("emailvoter")
    Membership.create!(user: member, group: @group, accepted_at: Time.current)

    poll = PollService.create(params: poll_params(
      closing_at: 7.days.from_now,
      opening_at: 3.days.from_now,
      notify_on_open: true
    ), actor: @user)
    ActionMailer::Base.deliveries.clear

    poll.update_column(:opening_at, 1.minute.ago)
    PollService.open_scheduled_polls

    announced_emails = ActionMailer::Base.deliveries.select { |m| m.to.include?(member.email) }
    assert_operator announced_emails.size, :>=, 1,
      "voter should receive email when poll opens with notify_on_open=true"
  end

  test "open_scheduled_polls delivers no emails to voters when notify_on_open is false" do
    member = create_unique_user("noemailvoter")
    Membership.create!(user: member, group: @group, accepted_at: Time.current)

    poll = PollService.create(params: poll_params(
      closing_at: 7.days.from_now,
      opening_at: 3.days.from_now,
      notify_on_open: false
    ), actor: @user)
    ActionMailer::Base.deliveries.clear

    poll.update_column(:opening_at, 1.minute.ago)
    PollService.open_scheduled_polls

    announced_emails = ActionMailer::Base.deliveries.select { |m| m.to.include?(member.email) }
    assert_equal 0, announced_emails.size,
      "voter should not receive email when poll opens with notify_on_open=false"
  end

  # -- group_members_added --

  test "adds new group members to non-specified-voters-only polls" do
    poll = create_poll(specified_voters_only: false)
    PollService.group_members_added(@group.id)
    count = poll.voters.count

    new_member = create_unique_user("newgroupmember")
    Membership.create!(user: new_member, group: @group, accepted_at: Time.current)
    PollService.group_members_added(@group.id)
    assert_equal count + 1, poll.voters.count
  end

  test "does not add bot users to polls" do
    poll = create_poll(specified_voters_only: false)
    PollService.group_members_added(@group.id)
    count = poll.voters.count

    bot = User.create!(name: 'Bot', email: "bot#{SecureRandom.hex(4)}@example.com",
                       email_verified: true, username: "bot#{SecureRandom.hex(4)}", bot: true)
    Membership.create!(user: bot, group: @group, accepted_at: Time.current)
    PollService.group_members_added(@group.id)
    assert_equal count, poll.voters.count
  end

  test "mark_closed_poll_topics_read creates missing group member readers and marks them read" do
    member = create_unique_user("closedpollreader")
    Membership.create!(user: member, group: @group, accepted_at: Time.current)
    poll = create_poll(specified_voters_only: false)
    PollService.close(poll: poll, actor: @user)
    poll.topic.topic_readers.where(user: member).delete_all

    stats = PollService.mark_closed_poll_topics_read

    reader = TopicReader.find_by!(topic: poll.topic, user: member)
    assert_equal poll.topic.reload.ranges, reader.read_ranges
    assert_not_nil reader.last_read_at
    assert_equal 0, reader.unread_items_count
    assert_operator stats[:readers_created], :>=, 1
  end

  test "mark_closed_poll_topics_read ignores active polls" do
    member = create_unique_user("activepollreader")
    Membership.create!(user: member, group: @group, accepted_at: Time.current)
    poll = create_poll(specified_voters_only: false)

    PollService.mark_closed_poll_topics_read

    assert_nil TopicReader.find_by(topic: poll.topic, user: member)
  end

  test "backfill_standalone_poll_stance_thread_items attaches visible stance events to standalone poll topics" do
    poll = create_poll(specified_voters_only: true)
    PollService.create_stances(poll: poll, actor: @user, user_ids: [@user.id])
    stance = poll.stances.latest.find_by!(participant_id: @user.id)
    stance.reason = "I agree"
    stance.choice = "Agree"
    stance.save!
    event = Events::StanceCreated.publish!(stance)

    event.update_columns(topic_id: nil, sequence_id: nil, parent_id: nil, position: 0, position_key: nil, depth: 0)
    TopicService.repair(poll.topic_id)
    poll.topic.reload

    assert_equal [poll.created_event.id], poll.topic.items.order(:sequence_id).pluck(:id)

    stats = PollService.backfill_standalone_poll_stance_thread_items(mark_closed_read: false)

    event.reload
    assert_equal poll.topic_id, event.topic_id
    assert_equal poll.created_event.id, event.parent_id
    assert_operator event.sequence_id, :>, 0
    assert_equal({ events: 1, topics: 1, repair_topics: 1 }, stats)
  end

  test "backfill_standalone_poll_stance_thread_items ignores blank stance events" do
    poll = create_poll(specified_voters_only: true)
    PollService.create_stances(poll: poll, actor: @user, user_ids: [@user.id])
    stance = poll.stances.latest.find_by!(participant_id: @user.id)
    stance.choice = "Agree"
    stance.save!
    event = Events::StanceCreated.publish!(stance)

    stats = PollService.backfill_standalone_poll_stance_thread_items(mark_closed_read: false)

    assert_nil event.reload.topic_id
    assert_equal({ events: 0, topics: 0, repair_topics: 0 }, stats)
  end

  test "backfill_standalone_poll_stance_thread_items repairs partially attached stance events" do
    poll = create_poll(specified_voters_only: true)
    PollService.create_stances(poll: poll, actor: @user, user_ids: [@user.id])
    stance = poll.stances.latest.find_by!(participant_id: @user.id)
    stance.reason = "I agree"
    stance.choice = "Agree"
    stance.save!
    event = Events::StanceCreated.publish!(stance)
    event.update_columns(topic_id: poll.topic_id, sequence_id: nil, parent_id: nil, position: 0, position_key: nil, depth: 0)

    stats = PollService.backfill_standalone_poll_stance_thread_items(mark_closed_read: false)

    event.reload
    assert_equal 0, stats[:events]
    assert_equal 0, stats[:topics]
    assert_equal 1, stats[:repair_topics]
    assert_equal poll.created_event.id, event.parent_id
    assert_operator event.sequence_id, :>, 0
  end

  test "backfill_standalone_poll_stance_thread_items marks closed poll topics totally read" do
    poll = create_poll(specified_voters_only: true)
    PollService.create_stances(poll: poll, actor: @user, user_ids: [@user.id])
    stance = poll.stances.latest.find_by!(participant_id: @user.id)
    stance.reason = "I agree"
    stance.choice = "Agree"
    stance.save!
    event = Events::StanceCreated.publish!(stance)
    event.update_columns(topic_id: nil, sequence_id: nil, parent_id: nil, position: 0, position_key: nil, depth: 0)
    TopicService.repair(poll.topic_id)
    PollService.close(poll: poll, actor: @user)

    reader = TopicReader.for(topic: poll.topic, user: @user)
    reader.viewed!([[0, 0]])

    stats = PollService.backfill_standalone_poll_stance_thread_items(mark_closed_read: true)

    assert_equal 0, reader.reload.unread_items_count
    assert_equal poll.topic.reload.ranges, reader.read_ranges
    assert_equal 1, stats[:repair_topics]
    assert_equal 1, stats[:closed_read][:topics]
    assert_operator stats[:closed_read][:readers_updated], :>=, 1
  end

  test "standalone_poll_topic_ids_newest_first orders newest polls first" do
    older_poll = create_poll(created_at: 2.days.ago)
    newer_poll = create_poll(created_at: 1.day.ago)

    assert_equal [newer_poll.topic_id, older_poll.topic_id],
      PollService.standalone_poll_topic_ids_newest_first([older_poll.topic_id, newer_poll.topic_id])
  end

  test "creates public topic when group requires public discussions" do
    open_group = Group.new(
      name: "Open Group #{SecureRandom.hex(4)}",
      group_privacy: 'open'
    )
    open_group.save!
    Membership.create!(user: @user, group: open_group, accepted_at: Time.current, admin: true)

    poll = PollService.create(
      params: poll_params(group_id: open_group.id),
      actor: @user
    )

    assert open_group.public_discussions_only?, "group should require public discussions"
    assert_equal false, poll.topic.private, "topic should be public for an open group"
  end

  private

  def poll_params(overrides = {})
    {
      title: "Test Poll #{SecureRandom.hex(4)}",
      poll_type: "proposal",
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 3.days.from_now,
      group_id: @group.id
    }.merge(overrides)
  end

  def create_poll(overrides = {})
    PollService.create(params: poll_params(overrides), actor: @user)
  end

  def create_unique_user(prefix)
    User.create!(
      name: prefix.titleize,
      email: "#{prefix}#{SecureRandom.hex(4)}@example.com",
      email_verified: true,
      username: "#{prefix}#{SecureRandom.hex(4)}"
    )
  end
end
