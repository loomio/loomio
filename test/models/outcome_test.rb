require 'test_helper'

class OutcomeTest < ActiveSupport::TestCase
  setup do
    @user = users(:user)
    @group = groups(:group)

    @meeting_poll = PollService.create(params: {
      poll_type: 'meeting',
      title: 'Meeting poll',
      closing_at: 5.days.from_now,
      group_id: @group.id,
      poll_option_names: ["2026-02-15"],
      notify_on_open: false
    }, actor: users(:admin))
    @meeting_poll.update!(closed_at: 1.day.ago)
  end

  test "stores some ical text for meeting polls" do
    selected_option = @meeting_poll.poll_options.first
    [@user, users(:member)].each do |voter|
      @meeting_poll.stances.latest.find_by!(participant: voter).update!(cast_at: Time.current,
        stance_choices_attributes: [{poll_option_id: selected_option.id, score: 2}])
    end
    outcome = Outcome.create!(
      poll: @meeting_poll,
      author: @user,
      statement: "Let's meet",
      poll_option: selected_option
    )
    calendar = Icalendar::Calendar.parse(outcome.calendar_invite).first
    event = calendar.events.first
    assert_equal [@user.email, users(:member).email].sort, event.attendee.map(&:to_s).sort
    assert_equal @user.email, event.organizer.to_s
    assert_equal Date.new(2026, 2, 15), event.dtstart.to_date
  end

  test "does nothing when no poll option is set" do
    outcome = Outcome.create!(
      poll: @meeting_poll,
      author: @user,
      statement: "Let's meet",
      poll_option: @meeting_poll.poll_options.first
    )
    outcome.update!(poll_option: nil)
    assert_nil outcome.calendar_invite
  end

  test "search indexing confines outcomes to the requested record poll or author" do
    target = Outcome.create!(poll: @meeting_poll, author: @user, statement: 'Requested outcome')
    other_author = Outcome.create!(poll: @meeting_poll, author: users(:member), statement: 'Other author')
    other_poll = PollService.create(params: {
      title: 'Separate poll', poll_type: 'proposal', group_id: @group.id,
      poll_option_names: %w[agree disagree], notify_on_open: false
    }, actor: users(:admin))
    other_outcome = Outcome.create!(poll: other_poll, author: @user, statement: 'Other poll')

    PgSearch::Document.delete_all
    target.update_pg_search_document
    assert_equal [target.id], PgSearch::Document.where(searchable_type: 'Outcome').pluck(:searchable_id)

    PgSearch::Document.delete_all
    SearchService.reindex_by_poll_id(@meeting_poll.id)
    assert_equal [target.id, other_author.id].sort,
      PgSearch::Document.where(searchable_type: 'Outcome').pluck(:searchable_id).sort

    PgSearch::Document.delete_all
    SearchService.reindex_by_author_id(@user.id)
    assert_equal [target.id, other_outcome.id].sort,
      PgSearch::Document.where(searchable_type: 'Outcome').pluck(:searchable_id).sort
  end
end
