require 'test_helper'

class InboundEmailRoutingJobTest < ActiveSupport::TestCase
  test 'a routing failure rolls back and retries the same message without duplicate discussions' do
    inbound = routing_email
    create_discussion = DiscussionService.method(:create)
    failed = false
    create = ->(**options) do
      discussion = create_discussion.call(**options)
      unless failed
        failed = true
        raise ActiveRecord::PreparedStatementCacheExpired, 'cached plan must not change result type'
      end
      discussion
    end

    travel_to Time.utc(2026, 10, 27, 12) do
      DiscussionService.stub(:create, create) do
        assert_no_difference 'Discussion.count' do
          assert_enqueued_with(job: ActionMailbox::RoutingJob, queue: 'action_mailbox_routing', args: [inbound]) do
            ActionMailbox::RoutingJob.perform_now(inbound)
          end
        end
        assert inbound.reload.failed?
        assert_nil inbound.processing_completed_at
        retry_job = enqueued_jobs.find { |job| job[:job] == ActionMailbox::RoutingJob }
        assert_operator retry_job[:at], :>, Time.current.to_f

        travel_to Time.at(retry_job[:at])
        assert_difference 'Discussion.count', 1 do
          perform_enqueued_jobs(only: ActionMailbox::RoutingJob, at: Time.current)
          ActionMailbox::RoutingJob.perform_now(inbound.reload)
        end
      end
      assert inbound.reload.delivered?
      assert inbound.processing_completed_at
      discussion = Discussion.find_by!(title: 'Retried inbound email')
      assert_equal users(:admin), discussion.author
      assert_equal groups(:group), discussion.group
      assert_no_enqueued_jobs(only: ActionMailbox::RoutingJob)
    end
  end

  test 'persistent routing failure schedules five increasingly delayed retries and then fails visibly' do
    inbound = routing_email
    attempts = 0
    process = ->(_) { attempts += 1; raise 'routing unavailable' }
    job = ActionMailbox::RoutingJob.new(inbound)
    delays = []

    travel_to Time.utc(2026, 10, 27, 12) do
      InboundEmailService.stub(:process, process) do
        5.times do
          assert_no_difference 'Discussion.count' do
            job.perform_now
          end
          retries = enqueued_jobs.select { |entry| entry[:job] == ActionMailbox::RoutingJob }
          assert_equal 1, retries.size
          retry_job = retries.first
          delays << retry_job[:at] - Time.current.to_f
          assert_operator delays.last, :>, 0
          job = ActiveJob::Base.deserialize(retry_job)
          clear_enqueued_jobs
          travel_to Time.at(retry_job[:at])
        end
        error = assert_raises(RuntimeError) { job.perform_now }
        assert_equal 'routing unavailable', error.message
      end
      assert_equal 6, attempts
      assert delays.each_cons(2).all? { |before, after| after > before }
      assert inbound.reload.failed?
      assert_nil inbound.processing_completed_at
      assert_no_enqueued_jobs(only: ActionMailbox::RoutingJob)
    end
  end

  private

  def routing_email
    build_inbound_email(headers: {from: users(:admin).email,
      to: "#{groups(:group).handle}@#{ENV.fetch('REPLY_HOSTNAME')}", subject: 'Retried inbound email'},
      body_text: 'Please discuss this')
  end
end
