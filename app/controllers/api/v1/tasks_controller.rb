class API::V1::TasksController < API::V1::RestfulController
  def visible_records
    Task.kept.joins("LEFT JOIN tasks_users ON tasks.id = tasks_users.task_id").
         where("tasks.author_id = :id or tasks_users.user_id = :id", id: current_user.id)
  end

  def mark_as_done
    @task = visible_records.find(params[:id])
    @task.done = true
    @task.done_at = Time.now

    record = @task.record

    doc = Nokogiri::HTML::DocumentFragment.parse(record.body)
    doc.css("li[data-uid='#{@task.uid}']").each do |li|
      li['data-checked'] = 'true'
    end

    record.body = doc.to_html
    record.save!

    @task.save

    respond_with_resource

    if record.group_id
      MessageChannelService.publish_models([record], group_id: record.group.id)
    end

    if record.respond_to?(:guests)
      record.guests.find_each do |user|
        MessageChannelService.publish_models([record], user_id: user.id)
      end
    end
  end

  def mark_as_not_done
    @task = visible_records.find(params[:id])
    @task.done = false
    @task.done_at = nil
    @task.save

    record = @task.record

    doc = Nokogiri::HTML::DocumentFragment.parse(record.body)
    doc.css("li[data-uid='#{@task.uid}']").each do |li|
      li['data-checked'] = 'false'
    end

    record.body = doc.to_html
    record.save!

    respond_with_resource

    if record.group_id
      MessageChannelService.publish_models([record], group_id: record.group.id)
    end

    if record.respond_to?(:guests)
      record.guests.find_each do |user|
        MessageChannelService.publish_models([record], user_id: user.id)
      end
    end
  end
end
