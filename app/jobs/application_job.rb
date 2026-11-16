class ApplicationJob < ActiveJob::Base
  queue_as :default

  around_perform do |_job, perform|
    SpamRules.with_context { perform.call }
  end
end
