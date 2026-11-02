require 'test_helper'

class PollLifecycleTest < ActiveSupport::TestCase
  setup do
    @actor = users(:admin)
    @params = {
      title: 'Scheduled decision', poll_type: 'proposal', group_id: groups(:group).id,
      poll_option_names: %w[agree disagree], closing_at: 3.days.from_now
    }
  end

  test 'minute checks enqueue due openings and closings without changing poll state' do
    opening = create_poll(opening_at: 1.day.from_now)
    opening.update_column(:opening_at, 1.minute.ago)
    closing = create_poll
    closing.update_column(:closing_at, 1.minute.ago)
    future = create_poll(opening_at: 1.day.from_now)
    clear_enqueued_jobs

    assert_enqueued_with(job: OpenScheduledPollWorker, args: [opening.id]) do
      OpenScheduledPollsWorker.perform_now
    end
    assert_enqueued_with(job: CloseExpiredPollWorker, args: [closing.id]) do
      ExpireLapsedPollsWorker.perform_now
    end

    assert_nil opening.reload.opened_at
    assert_nil closing.reload.closed_at
    assert_nil future.reload.opened_at
    assert_equal 2, enqueued_jobs.size
  end

  test 'repeated minute checks suppress duplicate closing jobs but allow different polls' do
    polls = 2.times.map { create_poll.tap { |poll| poll.update_column(:closing_at, 1.minute.ago) } }
    previous_adapter = CloseExpiredPollWorker.queue_adapter
    CloseExpiredPollWorker.queue_adapter = :solid_queue

    assert_difference 'SolidQueue::ReadyExecution.count', 2 do
      3.times { ExpireLapsedPollsWorker.perform_now }
    end
    jobs = SolidQueue::Job.where(class_name: 'CloseExpiredPollWorker')
    assert_equal polls.map(&:id).sort, jobs.map { |job| job.arguments['arguments'].first }.sort
    assert_equal 0, SolidQueue::BlockedExecution.where(job_id: jobs.select(:id)).count
  ensure
    CloseExpiredPollWorker.queue_adapter = previous_adapter
  end

  test 'queued expiry respects an extended deadline and a draft' do
    poll = create_poll
    poll.update_column(:closing_at, 1.minute.ago)
    PollService.update(poll: poll, params: { closing_at: 1.day.from_now }, actor: @actor)

    assert_no_difference 'Notification.count' do
      CloseExpiredPollWorker.perform_now(poll.id)
      poll.update!(closing_at: nil)
      CloseExpiredPollWorker.perform_now(poll.id)
    end
    assert_nil poll.reload.closed_at
  end

  test 'expiry closes a scheduled poll whose whole voting period passed during downtime' do
    poll = create_poll(opening_at: 1.day.from_now)
    poll.update_columns(opening_at: 2.hours.ago, closing_at: 1.hour.ago)

    perform_enqueued_jobs(only: CloseExpiredPollWorker) { ExpireLapsedPollsWorker.perform_now }

    assert poll.reload.closed_at
    assert_nil poll.opened_at
    assert_not Notification.exists?(kind: 'poll_announced', subject: poll.created_topic_item)
  end

  test 'a failed expiry notification rolls back closing and a retry closes once' do
    poll = create_poll
    poll.update_column(:closing_at, 1.minute.ago)

    NotificationService.stub(:create!, ->(**) { raise 'notification failed' }) do
      assert_raises(RuntimeError) { PollService.expire(poll: poll) }
    end
    assert_nil poll.reload.closed_at

    assert_difference -> { Notification.where(kind: 'poll_expired', subject: poll).count }, 1 do
      2.times { CloseExpiredPollWorker.perform_now(poll.id) }
    end
    assert poll.reload.closed_at
  end

  test 'queued opening respects rescheduling and expired voting periods' do
    poll = create_poll(opening_at: 1.day.from_now)
    assert_no_difference 'Notification.count' do
      OpenScheduledPollWorker.perform_now(poll.id)
      poll.update_columns(opening_at: 2.hours.ago, closing_at: 1.hour.ago)
      OpenScheduledPollWorker.perform_now(poll.id)
    end
    assert_nil poll.reload.opened_at
  end

  test 'discarded and deleted polls are ignored by queued lifecycle jobs' do
    poll = create_poll(opening_at: 1.day.from_now)
    poll.update_columns(opening_at: 1.minute.ago, discarded_at: Time.current)
    assert_no_difference 'Notification.count' do
      OpenScheduledPollWorker.perform_now(poll.id)
      poll.update_column(:closing_at, 1.minute.ago)
      CloseExpiredPollWorker.perform_now(poll.id)
      poll.destroy!
      OpenScheduledPollWorker.perform_now(poll.id)
      CloseExpiredPollWorker.perform_now(poll.id)
    end
  end

  private

  def create_poll(**params)
    PollService.create(params: @params.merge(params), actor: @actor)
  end
end
