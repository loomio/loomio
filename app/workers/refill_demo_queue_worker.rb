class RefillDemoQueueWorker < ApplicationJob
  def perform
    DemoService.refill_queue
  end
end
