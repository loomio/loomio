require "test_helper"

class QueueConfigurationTest < ActiveSupport::TestCase
  test "group destruction has one dedicated worker even when the general pool scales" do
    previous = ENV["JOB_CONCURRENCY"]
    ENV["JOB_CONCURRENCY"] = "4"
    config = YAML.safe_load(ERB.new(Rails.root.join("config/queue.yml").read).result, aliases: true)
    workers = config.fetch("production").fetch("workers")

    # Use Solid Queue's selector to verify the actual routing, including wildcard
    # selectors that would accidentally let the general pool claim deletion jobs.
    destruction = ready_execution(DestroyGroupWorker.new.queue_name)
    workers_for_destruction = workers.select do |worker|
      SolidQueue::QueueSelector.new(worker.fetch("queues"), SolidQueue::ReadyExecution.where(id: destruction.id))
                               .scoped_relations.any?(&:exists?)
    end
    assert_equal 1, workers_for_destruction.size
    assert_equal 1, workers_for_destruction.first.fetch("threads")
    assert_equal 1, workers_for_destruction.first.fetch("processes")

    job_classes = Rails.root.glob("app/{jobs,workers}/**/*.rb").map { |path| path.basename(".rb").to_s.camelize.constantize }
    job_classes += [ActiveStorage::AnalyzeJob, ActiveStorage::PurgeJob,
                    ActiveStorage::MirrorJob, ActiveStorage::TransformJob, ActiveStorage::PreviewImageJob,
                    ActionMailbox::RoutingJob, ActionMailbox::IncinerationJob]
    queue_names = job_classes.map { |klass| klass.new.queue_name }
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
