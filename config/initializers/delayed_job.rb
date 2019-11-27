Delayed::Worker.default_priority = 10
Delayed::Worker.max_attempts = ENV.fetch('MAX_JOB_ATTEMPTS', 2).to_i
Delayed::Worker.delay_jobs = ENV.fetch('RUN_JOBS_IN_BACKGROUND', Rails.env.production?)
Delayed::Worker.destroy_failed_jobs = (!ENV.fetch('KEEP_FAILED_JOBS', false))
Delayed::Worker.max_run_time = 15.minutes
Delayed::Worker.queue_attributes = {
  login_emails: { priority: -10 },
  invitation_emails: { priority: -5 },
  notification_emails: { priority: 0 },
  low_priority: { priority: 20 },
  catch_up_emails: { priority: 30 }
}
