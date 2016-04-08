Delayed::Worker.max_attempts = ENV['MAX_JOB_ATTEMPTS'] || 10
Delayed::Worker.delay_jobs = !(Rails.env.test? or Rails.env.development?)
