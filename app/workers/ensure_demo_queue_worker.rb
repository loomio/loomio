class EnsureDemoQueueWorker < ApplicationJob
  def perform
    DemoService.ensure_queue
  end
end
