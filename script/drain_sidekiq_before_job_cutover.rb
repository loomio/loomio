# frozen_string_literal: true

# Run before deploying the Solid Queue/Solid Cache/Solid Cable migration.
#
# This executes every queued and scheduled Sidekiq job, then removes each job
# from Redis after it succeeds. Run it while the old bundle still has Sidekiq
# installed.

require "sidekiq/api"

def run_sidekiq_job(job)
  puts "Running #{job.klass} #{job.args.inspect} jid=#{job.jid}"

  if job.klass == "ActiveJob::QueueAdapters::SidekiqAdapter::JobWrapper"
    active_job = ActiveJob::Base.deserialize(job.item.fetch("args").first)
    active_job.perform_now
  else
    job.klass.constantize.new.perform(*job.args)
  end

  job.delete
end

Sidekiq::Queue.all.each do |queue|
  queue.each { |job| run_sidekiq_job(job) }
end

Sidekiq::ScheduledSet.new.each do |job|
  run_sidekiq_job(job)
end

puts "Queued remaining: #{Sidekiq::Queue.all.sum(&:size)}"
puts "Scheduled remaining: #{Sidekiq::ScheduledSet.new.size}"
puts "Retries remaining: #{Sidekiq::RetrySet.new.size}"
puts "Dead remaining: #{Sidekiq::DeadSet.new.size}"
