class ReactivateUserWorker < ApplicationJob
  def perform(user_id)
    UserService.reactivate(user_id)
  end
end
