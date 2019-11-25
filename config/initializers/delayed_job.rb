Delayed::Worker.default_priority = 10
Delayed::Worker.max_attempts = ENV.fetch('MAX_JOB_ATTEMPTS', 2).to_i
Delayed::Worker.delay_jobs = ENV.fetch('RUN_JOBS_IN_BACKGROUND', Rails.env.production?)
Delayed::Worker.destroy_failed_jobs = (!ENV.fetch('KEEP_FAILED_JOBS', false))
Delayed::Worker.max_run_time = 5.minutes
