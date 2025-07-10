class Api::V1::TasksController < Api::V1::RestfulController
  def index
    # return tasks

    self.collection = Task.joins('left outer join tasks_users on tasks_users.task_id = tasks.id')
        .where("author_id = :user_id OR doer_id = :user_id OR tasks_users.user_id = :user_id", user_id: current_user.id)

    respond_with_collection
  end

  def update_done
    @task = Task.find_by(record: record, uid: params[:uid])
    current_user.ability.authorize!(:update, @task)

    TaskService.update_done(@task, current_user, params[:done] == 'true')

    respond_with_resource
    # we should also serialize the assocated record
  end

  def mark_as_done
    @task = Task.find(params[:id])
    current_user.ability.authorize!(:update, @task)

    TaskService.update_done(@task, current_user, true)

    respond_with_resource
    # we should also serialize the assocated record
  end

  def mark_as_not_done
    @task = Task.find(params[:id])
    current_user.ability.authorize!(:update, @task)

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
