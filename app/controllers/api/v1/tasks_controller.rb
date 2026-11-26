class Api::V1::TasksController < Api::V1::RestfulController
  def index
    if params[:group_id].present?
      group = Group.kept.find(params[:group_id])
      current_user.ability.authorize!(:show, group)

      group_ids = case params[:subgroups]
      when 'mine'
        [ group.id ] | (current_user.group_ids & group.id_and_subgroup_ids)
      when 'all'
        [ group.id ] | group.all_subgroups.kept.select { |sg| current_user.can?(:show, sg) }.map(&:id)
      else
        [ group.id ]
      end

      scope = group_tasks_scope(group_ids)
      if params[:user_id].present?
        uid = params[:user_id].to_i
        scope = scope
          .joins('LEFT OUTER JOIN tasks_users ON tasks_users.task_id = tasks.id')
          .where("tasks.author_id = :uid OR tasks.doer_id = :uid OR tasks_users.user_id = :uid", uid: uid)
          .distinct
      end

      self.collection = scope.includes(:record).select { |task| task.record.present? && current_user.can?(:show, task.record) }
    else
      self.collection = Task.kept.joins('left outer join tasks_users on tasks_users.task_id = tasks.id')
          .where("author_id = :user_id OR doer_id = :user_id OR tasks_users.user_id = :user_id", user_id: current_user.id)
          .distinct
          .select { |task| current_user.can?(:show, task) }
    end

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
  def group_tasks_scope(group_ids)
    discussion_ids = Discussion.kept.joins(:topic).where(topics: { group_id: group_ids, discarded_at: nil }).select(:id)
    poll_ids = Poll.kept.joins(:topic).where(topics: { group_id: group_ids, discarded_at: nil }).select(:id)
    comment_ids = Comment.kept
      .joins("INNER JOIN topic_items ON topic_items.itemable_type = 'Comment' AND topic_items.itemable_id = comments.id")
      .joins("INNER JOIN topics ON topics.id = topic_items.topic_id")
      .where(topics: { group_id: group_ids, discarded_at: nil })
      .select(:id)
    outcome_ids = Outcome.joins(poll: :topic).where(topics: { group_id: group_ids, discarded_at: nil }, polls: { discarded_at: nil }).select(:id)

    Task.kept.where(
      "(tasks.record_type = 'Discussion' AND tasks.record_id IN (:discussion_ids)) OR " \
      "(tasks.record_type = 'Poll' AND tasks.record_id IN (:poll_ids)) OR " \
      "(tasks.record_type = 'Comment' AND tasks.record_id IN (:comment_ids)) OR " \
      "(tasks.record_type = 'Outcome' AND tasks.record_id IN (:outcome_ids)) OR " \
      "(tasks.record_type = 'Group' AND tasks.record_id IN (:group_ids))",
      discussion_ids: discussion_ids,
      poll_ids: poll_ids,
      comment_ids: comment_ids,
      outcome_ids: outcome_ids,
      group_ids: group_ids
    )
  end

  def record
    load_and_authorize(:group, optional: true)      ||
    load_and_authorize(:discussion, optional: true) ||
    load_and_authorize(:comment, optional: true)    ||
    load_and_authorize(:poll, optional: true)       ||
    load_and_authorize(:outcome, optional: true)
  end
end
