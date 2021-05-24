class API::V1::TasksController < API::V1::RestfulController
  def visible_records
    Task.joins("LEFT JOIN tasks_users ON tasks.id = tasks_users.task_id").
         where("tasks.author_id = :id or tasks_users.user_id = :id", id: current_user.id)
  end
end
