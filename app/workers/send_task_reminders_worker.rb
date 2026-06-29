class SendTaskRemindersWorker < ApplicationJob
  def perform
    TaskService.send_task_reminders
  end
end
