require 'test_helper'

class PollServiceTest < ActiveSupport::TestCase
  setup do
    @user = users(:discussion_author)
    @another_user = users(:another_user)
    @group = groups(:test_group)
    @discussion = discussions(:test_discussion)
  end

  # -- create_stances --
  # Note: Use specified_voters_only polls so auto-creation doesn't preempt create_stances

  test "creates stance by user id" do
    poll = create_specified_voters_poll
    member = create_unique_user("stancemember")
    @group.add_admin!(@user)
    @group.add_member!(member)

    assert_equal 0, Stance.where(participant_id: member.id, poll: poll).where(revoked_at: nil).count
    PollService.create_stances(poll: poll, actor: @user, user_ids: [member.id])
    assert_equal 1, Stance.where(participant_id: member.id, poll: poll).where(revoked_at: nil).count
  end

  test "creates stance by email" do
    poll = create_specified_voters_poll
    member = create_unique_user("stanceemail")
    @group.add_admin!(@user)
    @group.add_member!(member)

    PollService.create_stances(poll: poll, actor: @user, emails: [member.email])
    assert_equal 1, Stance.where(participant_id: member.id, poll: poll).where(revoked_at: nil).count
  end

  test "creates stance by audience" do
    poll = create_specified_voters_poll
    member = create_unique_user("stanceaudience")
    @group.add_admin!(@user)
    @group.add_member!(member)

    PollService.create_stances(poll: poll, actor: @user, audience: 'group')
    assert_equal 1, Stance.where(participant_id: member.id, poll: poll).where(revoked_at: nil).count
  end

  test "only creates stances once per user" do
    poll = create_specified_voters_poll
    member = create_unique_user("stanceonce")
    @group.add_admin!(@user)
    @group.add_member!(member)

    PollService.create_stances(poll: poll, actor: @user, user_ids: [member.id])
    count = Stance.where(participant_id: member.id, poll: poll).where(revoked_at: nil).count
    assert_equal 1, count
    PollService.create_stances(poll: poll, actor: @user, user_ids: [member.id])
    assert_equal count, Stance.where(participant_id: member.id, poll: poll).where(revoked_at: nil).count
    PollService.create_stances(poll: poll, actor: @user, emails: [member.email])
    assert_equal count, Stance.where(participant_id: member.id, poll: poll).where(revoked_at: nil).count
  end

  test "uses normal volume by default for stances" do
    poll = create_specified_voters_poll
    member = create_unique_user("voldefault")
    @group.add_admin!(@user)
    @group.add_member!(member)

    PollService.create_stances(poll: poll, actor: @user, user_ids: [member.id])
    assert_equal 'normal', Stance.where(participant_id: member.id, poll: poll).order(created_at: :desc).first.email_volume
  end

  test "uses quiet discussion reader email_volume for stances" do
    poll = create_specified_voters_poll
    member = create_unique_user("volquiet")
    @group.add_admin!(@user)
    @group.add_member!(member)
    DiscussionReader.create!(user_id: member.id, discussion_id: @discussion.id, email_volume: 'quiet')

    PollService.create_stances(poll: poll, actor: @user, user_ids: [member.id])
    assert_equal 'quiet', Stance.where(participant_id: member.id, poll: poll).order(created_at: :desc).first.email_volume
  end

  test "uses quiet membership email_volume for stances" do
    poll = create_specified_voters_poll
    member = create_unique_user("volmembership")
    @group.add_admin!(@user)
    @group.add_member!(member)
    DiscussionReader.where(user_id: member.id).delete_all
    Membership.where(user_id: member.id).update_all(email_volume: Membership.email_volumes[:quiet])

    PollService.create_stances(poll: poll, actor: @user, user_ids: [member.id])
    assert_equal 'quiet', Stance.where(participant_id: member.id, poll: poll).order(created_at: :desc).first.email_volume
  end

  # -- create --

  test "creates a new poll" do
    poll = Poll.new(
      title: "New Poll",
      poll_type: "proposal",
      discussion: @discussion,
      author: @user,
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 3.days.from_now
    )
    assert_difference 'Poll.count', 1 do
      PollService.create(poll: poll, actor: @user)
    end
  end

  test "populates custom poll options" do
    poll = Poll.new(
      title: "Custom Poll",
      poll_type: "poll",
      discussion: @discussion,
      author: @user,
      poll_option_names: ["green"],
      closing_at: 3.days.from_now
    )
    PollService.create(poll: poll, actor: @user)
    assert_equal 1, poll.reload.poll_options.count
    assert_equal "green", poll.poll_options.first.name
  end

  test "does not create an invalid poll" do
    poll = Poll.new(
      title: "",
      poll_type: "proposal",
      discussion: @discussion,
      author: @user,
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 3.days.from_now
    )
    assert_no_difference 'Poll.count' do
      PollService.create(poll: poll, actor: @user)
    end
  end

  test "does not allow unauthorized users to create polls" do
    outsider = create_unique_user("pollunauthorized")
    poll = Poll.new(
      title: "Unauthorized Poll",
      poll_type: "proposal",
      discussion: @discussion,
      author: @user,
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 3.days.from_now
    )
    assert_raises CanCan::AccessDenied do
      PollService.create(poll: poll, actor: outsider)
    end
  end

  test "poll_created publishes poll_announced when notify_on_open is true" do
    poll = Poll.new(
      title: "No Email Poll",
      poll_type: "proposal",
      discussion: @discussion,
      author: @user,
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 3.days.from_now,
      notify_on_open: true
    )
    PollService.create(poll: poll, actor: @user)
    assert poll.opened?
    assert Event.where(kind: 'poll_announced', eventable: poll).exists?
  end

  test "poll_created does not publish poll_announced when notify_on_open is false" do
    poll = Poll.new(
      title: "No Email Poll",
      poll_type: "proposal",
      discussion: @discussion,
      author: @user,
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 3.days.from_now,
      notify_on_open: false
    )
    PollService.create(poll: poll, actor: @user)
    assert poll.opened?
    refute Event.where(kind: 'poll_announced', eventable: poll).exists?
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
    poll = Poll.new(
      title: "Scheduled Poll",
      poll_type: "proposal",
      discussion: @discussion,
      author: @user,
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 7.days.from_now,
      opening_at: 3.days.from_now,
      notify_on_open: true
    )
    PollService.create(poll: poll, actor: @user)
    refute poll.opened?, "poll should not be opened when opening_at is in the future"
    refute Event.where(kind: 'poll_announced', eventable: poll).exists?,
      "no poll_announced event should be created for scheduled poll at create time"
  end

  test "open_scheduled_polls opens scheduled polls and sends poll_announced when notify_on_open is true" do
    poll = Poll.new(
      title: "Scheduled Notify",
      poll_type: "proposal",
      discussion: @discussion,
      author: @user,
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 7.days.from_now,
      opening_at: 3.days.from_now,
      notify_on_open: true
    )
    PollService.create(poll: poll, actor: @user)
    refute poll.opened?

    # Simulate time passing: set opening_at to the past
    poll.update_column(:opening_at, 1.minute.ago)

    PollService.open_scheduled_polls
    poll.reload
    assert poll.opened?, "poll should be opened after open_scheduled_polls runs"
    assert Event.where(kind: 'poll_announced', eventable: poll).exists?,
      "poll_announced event should be created when notify_on_open is true"
  end

  test "open_scheduled_polls opens scheduled polls without poll_announced when notify_on_open is false" do
    poll = Poll.new(
      title: "Scheduled Silent",
      poll_type: "proposal",
      discussion: @discussion,
      author: @user,
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 7.days.from_now,
      opening_at: 3.days.from_now,
      notify_on_open: false
    )
    PollService.create(poll: poll, actor: @user)
    poll.update_column(:opening_at, 1.minute.ago)

    PollService.open_scheduled_polls
    poll.reload
    assert poll.opened?, "poll should be opened after open_scheduled_polls runs"
    refute Event.where(kind: 'poll_announced', eventable: poll).exists?,
      "no poll_announced event when notify_on_open is false"
  end

  test "open_scheduled_polls does not open polls whose opening_at is still in the future" do
    poll = Poll.new(
      title: "Future Poll",
      poll_type: "proposal",
      discussion: @discussion,
      author: @user,
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 7.days.from_now,
      opening_at: 3.days.from_now,
      notify_on_open: true
    )
    PollService.create(poll: poll, actor: @user)
    PollService.open_scheduled_polls
    poll.reload
    refute poll.opened?, "poll should not be opened when opening_at is still in the future"
  end

  # -- reopen --

  test "reopen sends poll_announced when notify_on_open is true" do
    poll = create_poll
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
    poll = create_poll
    poll.update!(notify_on_open: false)
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
    @group.add_admin!(@user)
    poll = Poll.new(
      title: "Scheduled Invite",
      poll_type: "proposal",
      discussion: @discussion,
      author: @user,
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 7.days.from_now,
      opening_at: 3.days.from_now,
      specified_voters_only: true,
      notify_on_open: true
    )
    PollService.create(poll: poll, actor: @user)
    refute poll.opened?

    member = create_unique_user("scheduledinvite")
    @group.add_member!(member)

    # Invite without notify_recipients (scheduled poll UI forces this off)
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
    @group.add_admin!(@user)
    member = create_unique_user("emailvoter")
    @group.add_member!(member)

    poll = Poll.new(
      title: "Email Test Poll",
      poll_type: "proposal",
      discussion: @discussion,
      author: @user,
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 7.days.from_now,
      opening_at: 3.days.from_now,
      notify_on_open: true
    )
    PollService.create(poll: poll, actor: @user)
    ActionMailer::Base.deliveries.clear

    poll.update_column(:opening_at, 1.minute.ago)
    PollService.open_scheduled_polls

    announced_emails = ActionMailer::Base.deliveries.select { |m| m.to.include?(member.email) }
    assert_operator announced_emails.size, :>=, 1,
      "voter should receive email when poll opens with notify_on_open=true"
  end

  test "open_scheduled_polls delivers no emails to voters when notify_on_open is false" do
    @group.add_admin!(@user)
    member = create_unique_user("noemailvoter")
    @group.add_member!(member)

    poll = Poll.new(
      title: "No Email Test Poll",
      poll_type: "proposal",
      discussion: @discussion,
      author: @user,
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 7.days.from_now,
      opening_at: 3.days.from_now,
      notify_on_open: false
    )
    PollService.create(poll: poll, actor: @user)
    ActionMailer::Base.deliveries.clear

    poll.update_column(:opening_at, 1.minute.ago)
    PollService.open_scheduled_polls

    announced_emails = ActionMailer::Base.deliveries.select { |m| m.to.include?(member.email) }
    assert_equal 0, announced_emails.size,
      "voter should not receive email when poll opens with notify_on_open=false"
  end

  # -- group_members_added --

  test "adds new group members to non-specified-voters-only polls" do
    poll = Poll.new(
      title: "Open Poll",
      poll_type: "proposal",
      discussion: @discussion,
      author: @user,
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 3.days.from_now,
      specified_voters_only: false
    )
    PollService.create(poll: poll, actor: @user)
    PollService.group_members_added(@group.id)
    count = poll.voters.count

    new_member = create_unique_user("newgroupmember")
    @group.add_member!(new_member)
    PollService.group_members_added(@group.id)
    assert_equal count + 1, poll.voters.count
  end

  test "does not add bot users to polls" do
    poll = Poll.new(
      title: "No Bots Poll",
      poll_type: "proposal",
      discussion: @discussion,
      author: @user,
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 3.days.from_now,
      specified_voters_only: false
    )
    PollService.create(poll: poll, actor: @user)
    PollService.group_members_added(@group.id)
    count = poll.voters.count

    bot = User.create!(name: 'Bot', email: "bot#{SecureRandom.hex(4)}@example.com",
                       email_verified: true, username: "bot#{SecureRandom.hex(4)}", bot: true)
    @group.add_member!(bot)
    PollService.group_members_added(@group.id)
    assert_equal count, poll.voters.count
  end

  private

  def create_poll
    poll = Poll.new(
      title: "Test Poll #{SecureRandom.hex(4)}",
      poll_type: "proposal",
      discussion: @discussion,
      author: @user,
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 3.days.from_now
    )
    PollService.create(poll: poll, actor: @user)
    poll.reload
  end

  def create_specified_voters_poll
    poll = Poll.new(
      title: "SVO Poll #{SecureRandom.hex(4)}",
      poll_type: "proposal",
      discussion: @discussion,
      author: @user,
      poll_option_names: ["Agree", "Disagree"],
      closing_at: 3.days.from_now,
      specified_voters_only: true
    )
    PollService.create(poll: poll, actor: @user)
    poll.reload
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
