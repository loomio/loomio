require 'test_helper'
require_relative '../support/event_poll_helper'

class EventPollTest < ActiveSupport::TestCase
  include EventPollHelper

  test 'legacy meeting records and new availability polls have the same voting rules' do
    poll = Poll.instantiate('poll_type' => 'meeting')
    assert_equal 'availability', poll.poll_type
    assert_equal 'time_poll', poll.vote_method
    assert Poll.new(poll_type: 'availability').prevent_anonymous
    assert_equal 'availability', PollTemplate.new(poll_type: 'meeting').poll_type
  end

  test 'event ballots have stable attendance meanings and cannot be anonymous or weighted' do
    poll = create_event_poll
    assert poll.calendar_uid.present?
    original_uid = poll.calendar_uid
    poll.reload
    assert_equal original_uid, poll.calendar_uid

    [{anonymous: true}, {weighted_voting: true}, {score_max: 2}, {choice_count_max: 2},
     {stance_reason_required: 'required'}, {event_ends_at: poll.event_starts_at - 1.minute},
     {time_zone: 'unknown'}].each do |attributes|
      candidate = Poll.find(poll.id)
      candidate.assign_attributes(attributes)
      assert_not candidate.valid?, attributes.inspect
    end
    poll.poll_options.load.first.mark_for_destruction
    assert_not poll.valid?
  end

  test 'rescheduling preserves old responses and requests fresh attendance' do
    poll = create_event_poll
    user = users(:member_normal)
    stance = poll.stances.latest.find_by!(participant: user)
    StanceService.update(stance: stance, actor: user,
      params: {stance_choices_attributes: [{poll_option_id: poll.poll_options.find_by!(icon: 'agree').id, score: 1}]})
    uid = poll.calendar_uid
    PollService.update(poll: poll, actor: users(:admin), params: {
      event_starts_at: poll.event_starts_at + 1.hour, event_ends_at: poll.event_ends_at + 1.hour
    })
    assert_equal 1, poll.reload.calendar_sequence
    assert_equal uid, poll.calendar_uid
    assert_not stance.reload.latest?
    assert stance.cast_at
    assert_nil poll.stances.latest.find_by!(participant: user).cast_at
    assert_equal 0, poll.vote_count_cast
  end

  test 'event cancellation closes attendance while retaining the event for calendar updates' do
    poll = create_event_poll
    PollService.cancel_event(poll: poll, actor: users(:admin))
    assert poll.reload.event_cancelled?
    assert_not poll.active?
    assert_equal 1, poll.calendar_sequence
    assert_raises(CanCan::AccessDenied) { PollService.reopen(poll: poll, actor: users(:admin), params: {closing_at: 4.days.from_now}) }
    assert_raises(CanCan::AccessDenied) { PollService.cancel_event(poll: create_event_poll, actor: users(:member_normal)) }
  end

  test 'event results count attendance separately from people who have not responded' do
    poll = create_event_poll
    user = users(:member_normal)
    StanceService.update(stance: poll.stances.latest.find_by!(participant: user), actor: user,
      params: {stance_choices_attributes: [{poll_option_id: poll.poll_options.find_by!(icon: 'agree').id, score: 1}]})
    poll.reload
    assert_equal %w[name vote_count voters], poll.result_columns
    assert_equal 'calendar.attendance', poll.result_heading_keys['name']
    assert_equal 'calendar.people', poll.result_heading_keys['vote_count']
    assert_equal 1, poll.results.find { |result| result['icon'] == 'agree' }.fetch('vote_count')
    assert_equal 0, poll.results.find { |result| result['icon'] == 'disagree' }.fetch('vote_count')
    uncast = poll.results.find { |result| result['id'] == -1 }
    assert_equal 'calendar.no_response', uncast.fetch('name')
    assert_equal poll.vote_count_eligible - 1, uncast.fetch('vote_count')
  end
end
