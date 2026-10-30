require 'test_helper'
require_relative '../support/event_poll_helper'

class CalendarReplyServiceTest < ActiveSupport::TestCase
  include EventPollHelper

  setup do
    freeze_time
    @poll = create_event_poll
    @invitation = calendar_invitation(@poll)
  end

  test 'calendar responses cast ordinary attendance votes and remain outside the comment pipeline' do
    {'ACCEPTED' => 'agree', 'TENTATIVE' => 'abstain', 'DECLINED' => 'disagree'}.each_with_index do |(status, icon), index|
      travel 1.second
      inbound = calendar_reply(@invitation, status: status)
      assert_no_difference 'Comment.count' do
        assert_equal :delivered, InboundEmailService.process(inbound)
      end
      stance = @poll.stances.latest.find_by!(participant: @invitation.user)
      assert_equal icon, stance.stance_choices.sole.poll_option.icon
      assert inbound.reload.processing_completed_at
      assert_equal :delivered, InboundEmailService.process(inbound)
      assert_equal 1, @poll.reload.vote_count_cast
    end
  end

  test 'sender attendee organizer uid revision and authenticated origin must match' do
    [
      {sender: users(:alien).email}, {attendee: users(:alien).email},
      {organizer: 'somebody@example.com'}, {uid: 'different-event'}, {sequence: 1},
      {status: 'DELEGATED'}, {method: 'REQUEST'},
      {authentication: 'mx.test; dmarc=fail header.from=example.com'},
      {authentication: 'mx.test; dmarc=pass header.from=attacker.example'},
      {authentication: 'mx.test; spf=pass'}, {stamp: 1.day.from_now}
    ].each do |attributes|
      assert_equal :bounced, InboundEmailService.process(calendar_reply(@invitation, **attributes)), attributes.inspect
      assert_nil @poll.stances.latest.find_by!(participant: @invitation.user).cast_at
    end
  end

  test 'mailbox normalization accepts casing differences without merging aliases' do
    reply = calendar_reply(@invitation, sender: @invitation.email.upcase, attendee: @invitation.email.upcase)
    assert_equal :delivered, InboundEmailService.process(reply)

    other = calendar_invitation(@poll, users(:member_loud))
    local, domain = other.email.split('@', 2)
    assert_equal :bounced, InboundEmailService.process(calendar_reply(other, sender: "#{local}+different@#{domain}"))
  end

  test 'authenticated Google Calendar notifications can confirm the invited attendee' do
    reply = calendar_reply(@invitation, sender: 'calendar-notification@google.com',
      authentication: 'mx.loomio.test; dkim=pass header.d=google.com')
    assert_equal :delivered, InboundEmailService.process(reply)
    assert_equal 'agree', @poll.stances.latest.find_by!(participant: @invitation.user).stance_choices.sole.poll_option.icon
  end

  test 'provider-looking senders cannot bypass the signature or attendee binding' do
    [
      {sender: 'calendar-notification@google.com', authentication: 'mx.test; dmarc=pass header.from=google.com'},
      {sender: 'calendar-notification@google.com', authentication: 'mx.test; dmarc=pass header.from=google.com; dkim=pass header.d=attacker.example'},
      {sender: 'calendar-notification@google.com.evil.example'},
      {sender: 'different@google.com', authentication: 'mx.test; dkim=pass header.d=google.com'},
      {sender: 'calendar-notification@google.com', authentication: 'mx.test; dkim=pass header.d=google.com', attendee: users(:alien).email}
    ].each do |attributes|
      assert_equal :bounced, InboundEmailService.process(calendar_reply(@invitation, **attributes)), attributes.inspect
      assert_nil @poll.stances.latest.find_by!(participant: @invitation.user).cast_at
    end
  end

  test 'old replies cannot undo newer calendar or Loomio responses' do
    old_reply = calendar_reply(@invitation, status: 'DECLINED')
    travel 1.minute
    assert_equal :delivered, InboundEmailService.process(calendar_reply(@invitation))
    assert_equal :bounced, InboundEmailService.process(old_reply)
    assert_equal 'agree', @poll.stances.latest.find_by!(participant: @invitation.user).stance_choices.sole.poll_option.icon

    old_reply = calendar_reply(@invitation, status: 'DECLINED')
    travel 1.minute
    stance = @poll.stances.latest.find_by!(participant: @invitation.user)
    StanceService.update(stance: stance, actor: @invitation.user,
      params: {stance_choices_attributes: [{poll_option_id: @poll.poll_options.find_by!(icon: 'abstain').id, score: 1}]})
    assert_equal :bounced, InboundEmailService.process(old_reply)
    assert_equal 'abstain', @poll.stances.latest.find_by!(participant: @invitation.user).stance_choices.sole.poll_option.icon
  end

  test 'replies to an earlier schedule cannot confirm the new time' do
    old_reply = calendar_reply(@invitation)
    PollService.update(poll: @poll, actor: users(:admin), params: {
      event_starts_at: @poll.event_starts_at + 1.hour, event_ends_at: @poll.event_ends_at + 1.hour
    })
    assert_equal :bounced, InboundEmailService.process(old_reply)
    assert_nil @poll.stances.latest.find_by!(participant: @invitation.user).cast_at
  end

  test 'revoked inactive and foreign readers cannot vote through a retained invitation' do
    %i[former_member_loud former_guest_loud inactive_member_loud inactive_guest_loud non_guest_loud alien_loud].each do |role|
      user = users(role)
      invitation = calendar_invitation(@poll, user)
      assert_equal :bounced, InboundEmailService.process(calendar_reply(invitation)), role.to_s
    end
    @invitation.user.memberships.active.where(group: @poll.group).update_all(revoked_at: Time.current)
    assert_equal :bounced, InboundEmailService.process(calendar_reply(@invitation))
  end

  test 'direct event guests can respond but revoked direct guests cannot' do
    poll = create_event_poll(topic: topics(:direct_topic), actor: users(:guest_admin_normal))
    guest = calendar_invitation(poll, users(:guest_normal))
    assert_equal :delivered, InboundEmailService.process(calendar_reply(guest))
    revoked = calendar_invitation(poll, users(:former_guest_loud))
    assert_equal :bounced, InboundEmailService.process(calendar_reply(revoked))
  end

  test 'cancelled events reject calendar voting' do
    PollService.cancel_event(poll: @poll, actor: users(:admin))
    assert_equal :bounced, InboundEmailService.process(calendar_reply(@invitation))
  end

  test 'closed discarded and ordinary polls reject calendar voting' do
    [{closed_at: Time.current}, {discarded_at: Time.current}, {poll_type: 'poll'}].each do |attributes|
      poll = create_event_poll
      invitation = calendar_invitation(poll)
      reply = calendar_reply(invitation)
      poll.update_columns(attributes)
      assert_no_difference 'AnonymousBallot.count' do
        assert_equal :bounced, InboundEmailService.process(reply), attributes.inspect
      end
    end
  end

  test 'public visibility does not let a former member confirm attendance' do
    users(:admin).memberships.create!(group: groups(:public_group), admin: true)
    poll = create_event_poll(topic: topics(:public_discussion_topic))
    user = users(:member_normal)
    membership = poll.group.add_member!(user)
    PollService.create_anyone_can_vote_stances(poll)
    invitation = calendar_invitation(poll, user)
    membership.update!(revoked_at: Time.current)
    assert user.can?(:show, poll)
    assert_equal :bounced, InboundEmailService.process(calendar_reply(invitation))
  end

  test 'malformed calendar content is rejected without creating a comment' do
    inbound = calendar_reply(@invitation)
    mail = inbound.mail
    mail.body = 'not an iCalendar document'
    malformed = store_inbound_mail(mail.tap { |message| message.message_id = SecureRandom.uuid })
    assert_no_difference 'Comment.count' do
      assert_equal :bounced, InboundEmailService.process(malformed)
    end
  end
end
