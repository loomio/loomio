class DestroyExpiredDemoGroupsWorker < ApplicationJob
  def perform
    DemoService.destroy_expired_demo_groups
  end
end
