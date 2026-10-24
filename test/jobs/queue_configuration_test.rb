require "test_helper"

class QueueConfigurationTest < ActiveSupport::TestCase
  test "every production recurring task has a worker that can claim its jobs" do
    config = YAML.safe_load(ERB.new(Rails.root.join("config/queue.yml").read).result, aliases: true)
    workers = config.fetch("production").fetch("workers")
    tasks = YAML.safe_load(Rails.root.join("config/recurring.yml").read).fetch("production")

    tasks.each do |key, options|
      task = SolidQueue::RecurringTask.from_configuration(key, **options.symbolize_keys)
      active_job = task.enqueue(at: Time.current)
      execution = ready_execution(active_job.queue_name)

      assert workers.any? { |worker|
        SolidQueue::QueueSelector.new(worker.fetch("queues"), SolidQueue::ReadyExecution.where(id: execution.id))
                                 .scoped_relations.any?(&:exists?)
      }, "No worker serves recurring task #{key} on #{active_job.queue_name}"
    end
  end

  test "group destruction and count repair each have a dedicated worker when the general pool scales" do
    previous = ENV["JOB_CONCURRENCY"]
    ENV["JOB_CONCURRENCY"] = "4"
    config = YAML.safe_load(ERB.new(Rails.root.join("config/queue.yml").read).result, aliases: true)
    workers = config.fetch("production").fetch("workers")

    # Use Solid Queue's selector to verify the actual routing, including wildcard
    # selectors that would accidentally let the general pool claim deletion jobs.
    [DestroyGroupWorker, RepairRecordCountsWorker].each do |job_class|
      job = ready_execution(job_class.new.queue_name)
      selected_workers = workers.select do |worker|
        SolidQueue::QueueSelector.new(worker.fetch("queues"), SolidQueue::ReadyExecution.where(id: job.id))
                                 .scoped_relations.any?(&:exists?)
      end
      assert_equal 1, selected_workers.size, job_class.name
      assert_equal 1, selected_workers.first.fetch("threads"), job_class.name
      assert_equal 1, selected_workers.first.fetch("processes"), job_class.name
    end

    job_classes = Rails.root.glob("app/{jobs,workers}/**/*.rb").map { |path| path.basename(".rb").to_s.camelize.constantize }
    job_classes += [ActiveStorage::AnalyzeJob, ActiveStorage::PurgeJob,
                    ActiveStorage::MirrorJob, ActiveStorage::TransformJob, ActiveStorage::PreviewImageJob,
                    ActionMailbox::RoutingJob, ActionMailbox::IncinerationJob]
    # Mail delivery jobs, including subclasses, resolve their queue from a mailer argument.
    queue_names = job_classes.map do |klass|
      job = klass <= ActionMailer::MailDeliveryJob ? klass.new("ForwardMailer") : klass.new
      job.queue_name
    end
    queue_names << ActionMailer::MailDeliveryJob.new("UserMailer").queue_name
    queue_names.uniq.each do |queue_name|
      job = ready_execution(queue_name)
      assert workers.any? { |worker|
        SolidQueue::QueueSelector.new(worker.fetch("queues"), SolidQueue::ReadyExecution.where(id: job.id))
                                 .scoped_relations.any?(&:exists?)
      }, "No worker serves #{queue_name}"
    end
  ensure
    previous.nil? ? ENV.delete("JOB_CONCURRENCY") : ENV["JOB_CONCURRENCY"] = previous
  end

  private

  def ready_execution(queue_name)
    job = SolidQueue::Job.create!(class_name: "ApplicationJob", queue_name: queue_name, arguments: {})
    SolidQueue::ReadyExecution.find_by!(job_id: job.id)
  end
end
