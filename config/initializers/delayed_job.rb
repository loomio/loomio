Delayed::Worker.max_attempts = 10
Delayed::Worker.delay_jobs = !(Rails.env.test? or Rails.env.development?)
