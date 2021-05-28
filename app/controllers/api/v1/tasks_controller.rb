class API::V1::TasksController < API::V1::RestfulController
  def visible_records
    Task.kept.joins("LEFT JOIN tasks_users ON tasks.id = tasks_users.task_id").
         where("tasks.author_id = :id or tasks_users.user_id = :id", id: current_user.id)
  end

  def update_done
    @task = visible_records.find_by(record: record, uid: params[:uid])

    TaskService.update_done(@task, current_user, params[:done] == 'true')

    respond_with_resource
    # we should also serialize the assocated record
  end

  def mark_as_done
    @task = visible_records.find(params[:id])

    TaskService.update_done(@task, current_user, true)

    respond_with_resource
    # we should also serialize the assocated record
  end

  def mark_as_not_done
    @task = visible_records.find(params[:id])

    TaskService.update_done(@task, current_user, false)

    respond_with_resource
  end

  private
  def record
    load_and_authorize(:group, optional: true)      ||
    load_and_authorize(:discussion, optional: true) ||
    load_and_authorize(:comment, optional: true)    ||
    load_and_authorize(:poll, optional: true)       ||
    load_and_authorize(:outcome, optional: true)
  end
end
