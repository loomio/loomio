class GroupCalendarService
  include PrettyUrlHelper

  ITEMS_MAX = 1000

  def initialize(group:, user:, starts_at:, ends_at:)
    @group, @user, @starts_at, @ends_at = group, user, starts_at, ends_at
  end

  def entries
    items.map { |item| item.except(:component) }
  end

  def to_ical
    calendar = Icalendar::Calendar.new
    calendar.prodid = '-//Loomio//Group calendar//EN'
    calendar.append_custom_property('X-WR-CALNAME', @group.name)
    items.each { |item| calendar.add_event(item.fetch(:component)) }
    calendar.to_ical
  end

  private

  # Query visibility afresh for each fetch. No participant data, poll results,
  # reasons, or discussion bodies enter the subscription representation.
  def items
    @items ||= begin
      polls = PollQuery.visible_to(user: @user, chain: Poll.kept, group_ids: [@group.id])
        .joins(:topic).where('topics.group_id': @group.id)
      events = polls.where(poll_type: 'event').where('event_starts_at < ? AND event_ends_at >= ?', @ends_at, @starts_at)
        .order(:event_starts_at, :id).limit(ITEMS_MAX).map { |poll| event_item(poll) }
      deadlines = polls.where.not(poll_type: 'event').where(opened_at: ..Time.current, closing_at: @starts_at...@ends_at, closed_at: nil)
        .order(:closing_at, :id).limit(ITEMS_MAX).map { |poll| deadline_item(poll) }
      reviews = Outcome.latest.where(poll_id: polls.except(:includes).select(:id), review_on: @starts_at.to_date...@ends_at.to_date)
        .includes(:poll).order(:review_on, :id).limit(ITEMS_MAX).map { |outcome| review_item(outcome) }
      (events + deadlines + reviews).sort_by { |item| [item[:start], item[:id]] }
    end
  end

  def event_item(poll)
    component = EventCalendarService.new.event(poll, include_details: false)
    component.transp = 'TRANSPARENT'
    starts_at = poll.event_all_day? ? poll.event_starts_at.in_time_zone(poll.time_zone).to_date.iso8601 : poll.event_starts_at.iso8601
    ends_at = poll.event_all_day? ? poll.event_ends_at.in_time_zone(poll.time_zone).to_date.iso8601 : poll.event_ends_at.iso8601
    {id: poll.calendar_uid, name: poll.title, start: starts_at, end: ends_at, timed: !poll.event_all_day?,
     kind: 'event', cancelled: poll.event_cancelled?, url: poll_url(poll), component: component}
  end

  def deadline_item(poll)
    name = I18n.t('calendar.deadline', title: poll.title)
    component = marker(uid: "deadline-#{poll.key}@loomio", name: name, url: poll_url(poll), updated_at: poll.updated_at)
    component.dtstart = Icalendar::Values::DateTime.new(poll.closing_at.utc, tzid: 'UTC')
    {id: component.uid.to_s, name: name, start: poll.closing_at.iso8601, end: poll.closing_at.iso8601,
     timed: true, kind: 'deadline', url: poll_url(poll), component: component}
  end

  def review_item(outcome)
    name = I18n.t('calendar.review', title: outcome.poll.title)
    component = marker(uid: "review-#{outcome.id}@loomio", name: name, url: poll_url(outcome.poll), updated_at: [outcome.updated_at, outcome.poll.updated_at].max)
    component.dtstart = Icalendar::Values::Date.new(outcome.review_on)
    component.dtend = Icalendar::Values::Date.new(outcome.review_on + 1.day)
    {id: component.uid.to_s, name: name, start: outcome.review_on.iso8601, end: (outcome.review_on + 1.day).iso8601,
     timed: false, kind: 'review', url: poll_url(outcome.poll), component: component}
  end

  def marker(uid:, name:, url:, updated_at:)
    Icalendar::Event.new.tap do |item|
      item.uid = uid
      item.summary = name
      item.url = url
      item.description = url
      item.dtstamp = updated_at.utc
      item.last_modified = updated_at.utc
      item.transp = 'TRANSPARENT'
      item.ip_class = 'PRIVATE'
    end
  end
end
