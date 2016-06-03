Delayed::Worker.default_priority = 10
Delayed::Worker.max_attempts = ENV['MAX_JOB_ATTEMPTS'] || 10
Delayed::Worker.delay_jobs = Rails.env.production?
