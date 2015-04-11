Delayed::Worker.max_attempts = 2
Delayed::Worker.delay_jobs = !(Rails.env.test? or Rails.env.development?)
