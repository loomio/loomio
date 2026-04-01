require 'test_helper'

class CalendarRsvpServiceTest < ActionMailbox::TestCase
  setup do
    hex = SecureRandom.hex(4)
    @user = User.create!(name: "rsvp#{hex}", email: "rsvp#{hex}@example.com", username: "rsvp#{hex}", email_verified: true)
    @group = Group.new(name: "rsvpgrp#{hex}", group_privacy: 'secret')
    @group.creator = @user
    @group.save!
    @group.add_admin!(@user)

    @voter = User.create!(name: "voter#{hex}", email: "voter#{hex}@example.com", username: "voter#{hex}", email_verified: true)
    @group.add_member!(@voter)

    @discussion = Discussion.new(title: "RSVP Discussion #{hex}", group: @group, author: @user)
    DiscussionService.create(discussion: @discussion, actor: @user)

    @poll = Poll.new(
      title: "RSVP Proposal #{hex}",
      poll_type: 'proposal',
      group: @group,
      discussion: @discussion,
      author: @user,
      closing_at: 3.days.from_now,
      poll_option_names: %w[agree disagree abstain]
    )
    PollService.create(poll: @poll, actor: @user)
    ActionMailer::Base.deliveries.clear
  end

  test "accept rsvp casts agree vote" do
    assert_rsvp_casts_vote("ACCEPTED", "agree")
  end

  test "decline rsvp casts disagree vote" do
    assert_rsvp_casts_vote("DECLINED", "disagree")
  end

  test "tentative rsvp casts abstain vote" do
    assert_rsvp_casts_vote("TENTATIVE", "abstain")
  end

  test "ignores non-reply calendar emails" do
    ics = build_ics(method: "REQUEST", partstat: "NEEDS-ACTION")
    mail = build_rsvp_mail(ics: ics)
    assert_not CalendarRsvpService.process(mail)
  end

  test "ignores rsvp for non-proposal polls" do
    @poll.update_columns(poll_type: 'poll')
    ics = build_ics(partstat: "ACCEPTED")
    mail = build_rsvp_mail(ics: ics)
    assert_not CalendarRsvpService.process(mail)
  end

  test "ignores rsvp for closed polls" do
    @poll.update_columns(closed_at: 1.hour.ago)
    ics = build_ics(partstat: "ACCEPTED")
    mail = build_rsvp_mail(ics: ics)
    assert_not CalendarRsvpService.process(mail)
  end

  test "ignores rsvp with invalid credentials" do
    ics = build_ics(partstat: "ACCEPTED")
    mail = build_rsvp_mail(ics: ics, to: "pt=p&pi=#{@poll.id}&d=#{@discussion.id}&u=#{@voter.id}&k=badkey@#{ENV['REPLY_HOSTNAME']}")
    assert_not CalendarRsvpService.process(mail)
  end

  test "ignores rsvp with unrecognised uid" do
    ics = build_ics(partstat: "ACCEPTED", uid: "other-thing-123@example.com")
    mail = build_rsvp_mail(ics: ics)
    assert_not CalendarRsvpService.process(mail)
  end

  test "build_ics generates valid calendar invite" do
    reply_to = "pt=p&pi=#{@poll.id}&d=#{@discussion.id}&u=#{@voter.id}&k=#{@voter.email_api_key}@#{ENV['REPLY_HOSTNAME']}"
    ics = CalendarRsvpService.build_ics(poll: @poll, recipient: @voter, reply_to: reply_to)

    calendars = Icalendar::Calendar.parse(ics)
    cal = calendars.first
    assert_equal "REQUEST", cal.ip_method.to_s
    event = cal.events.first
    assert_equal "loomio-poll-#{@poll.id}@#{ENV['CANONICAL_HOST']}", event.uid.to_s
    assert_includes event.summary.to_s, @poll.title
    attendee = Array(event.attendee).first
    assert_includes attendee.to_s, @voter.email
  end

  private

  def build_ics(partstat:, method: "REPLY", uid: nil)
    uid ||= "loomio-poll-#{@poll.id}@#{ENV['CANONICAL_HOST']}"
    <<~ICS
      BEGIN:VCALENDAR
      VERSION:2.0
      PRODID:-//Test//Test//EN
      METHOD:#{method}
      BEGIN:VEVENT
      UID:#{uid}
      ATTENDEE;CN=#{@voter.name};PARTSTAT=#{partstat}:mailto:#{@voter.email}
      END:VEVENT
      END:VCALENDAR
    ICS
  end

  def build_rsvp_mail(ics:, from: nil, to: nil)
    from ||= @voter.email
    to ||= "pt=p&pi=#{@poll.id}&d=#{@discussion.id}&u=#{@voter.id}&k=#{@voter.email_api_key}@#{ENV['REPLY_HOSTNAME']}"

    Mail.new do |m|
      m.from = from
      m.to = to
      m.subject = "Accepted: #{@poll.title}"

      m.text_part = Mail::Part.new do
        body ""
      end

      calendar_part = Mail::Part.new
      calendar_part.content_type = "text/calendar; method=REPLY; charset=UTF-8"
      calendar_part.body = ics
      m.add_part(calendar_part)
    end
  end

  def assert_rsvp_casts_vote(partstat, expected_option_name)
    stance = @poll.stances.latest.find_by(participant: @voter)
    assert stance, "voter should have a stance"
    assert_nil stance.cast_at, "stance should not be cast yet"

    ics = build_ics(partstat: partstat)
    mail = build_rsvp_mail(ics: ics)
    assert CalendarRsvpService.process(mail)

    stance.reload
    assert stance.cast_at, "stance should now be cast"
    chosen_option = stance.poll_options.first
    assert_equal expected_option_name, chosen_option.icon
  end
end
