Delayed::Worker.default_priority = 10
Delayed::Worker.max_attempts = ENV.fetch('MAX_JOB_ATTEMPTS', 3).to_i
Delayed::Worker.delay_jobs = ENV.fetch('RUN_JOBS_IN_BACKGROUND', Rails.env.production?)
