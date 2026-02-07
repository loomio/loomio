require 'test_helper'

class TaskServiceTest < ActiveSupport::TestCase
  setup do
    @member = users(:normal_user)
    @member.update(username: 'sam', name: 'Sam Sammy')
    @group = groups(:test_group)
    @group.add_member!(@member) unless @group.members.include?(@member)
    @discussion = create_discussion(group: @group, author: @member)
    ActionMailer::Base.deliveries.clear
  end

  test "parses a simple task from HTML" do
    rich_text = "<li data-uid='123' data-type='taskItem' data-checked='false' data-author-id='1'>this is a task</li>"
    tasks_data = TaskService.parse_tasks(rich_text, @member)

    assert_equal 1, tasks_data.size
    assert_equal 123, tasks_data.first[:uid]
    assert_equal "this is a task", tasks_data.first[:name]
    assert_nil tasks_data.first[:due_on]
    assert_empty tasks_data.first[:usernames]
    assert_equal false, tasks_data.first[:done]
    assert_equal 1, tasks_data.first[:author_id]
  end

  test "parses a complex task from HTML" do
    rich_text = "<li data-uid='123' data-type='taskItem' data-checked='true' data-author-id='1' data-remind='0' data-due-on='2022-05-02'>this is a task for <span data-mention-id='#{@member.username}'>#{@member.name}</span></li>"
    tasks_data = TaskService.parse_tasks(rich_text, @member)

    assert_equal 1, tasks_data.size
    assert_equal 123, tasks_data.first[:uid]
    assert_equal "this is a task for Sam Sammy", tasks_data.first[:name]
    assert_equal Date.parse("2022-05-02"), tasks_data.first[:due_on]
    assert_includes tasks_data.first[:usernames], 'sam'
    assert_equal true, tasks_data.first[:done]
    assert_equal 1, tasks_data.first[:author_id]
    assert_equal 0, tasks_data.first[:remind]
  end

  test "creates a task" do
    rich_text = "<li data-uid='123' data-type='taskItem' data-checked='true' data-author-id='#{@member.id}' data-due-on='2022-05-02'>this is a task for <span data-mention-id='#{@member.username}'>#{@member.name}</span></li>"
    tasks_data = TaskService.parse_tasks(rich_text, @member)
    TaskService.update_model(@discussion, tasks_data)

    assert_equal 1, @discussion.tasks.count
    assert_equal 123, @discussion.tasks.first.uid
    assert_equal "this is a task for Sam Sammy", @discussion.tasks.first.name
    assert_equal Date.parse("2022-05-02"), @discussion.tasks.first.due_on
    assert_includes @discussion.tasks.first.users, @member
    assert_equal true, @discussion.tasks.first.done
    assert_equal @member, @discussion.tasks.first.author
    assert_nil @discussion.tasks.first.remind
  end

  test "updates a task" do
    # Create initial task
    rich_text = "<li data-uid='123' data-type='taskItem' data-checked='false' data-author-id='#{@member.id}' data-remind='1' data-due-on='2022-05-02'>this is a task due 2022-05-02</li>"
    tasks_data = TaskService.parse_tasks(rich_text, @member)
    TaskService.update_model(@discussion, tasks_data)
    task = @discussion.tasks.first

    assert_equal 123, task.uid
    assert_equal "this is a task due 2022-05-02", task.name
    assert_equal Date.parse("2022-05-02"), task.due_on
    assert_empty task.users
    assert_equal @member, task.author
    assert_equal false, task.done
    assert_nil task.done_at
    assert_equal 1, task.remind

    # Update the task
    rich_text = "<li data-uid='123' data-type='taskItem' data-checked='true' data-author-id='#{@member.id}' data-due-on='2022-06-01'>this is a task for <span data-mention-id='#{@member.username}'>#{@member.name}</span></li>"
    tasks_data = TaskService.parse_tasks(rich_text, @member)
    TaskService.update_model(@discussion, tasks_data)

    task.reload

    assert_equal "this is a task for Sam Sammy", task.name
    assert_equal Date.parse("2022-06-01"), task.due_on
    assert_includes task.users, @member
    assert_equal true, task.done
    assert_not_nil task.done_at
  end

  test "destroys a task" do
    rich_text = "<li data-uid='123' data-type='taskItem'>this is a task</li>"
    tasks_data = TaskService.parse_tasks(rich_text, @member)
    TaskService.update_model(@discussion, tasks_data)
    assert_equal 1, @discussion.tasks.count

    # Parse empty HTML (no tasks)
    tasks_data = TaskService.parse_tasks("", @member)
    TaskService.update_model(@discussion, tasks_data)
    @discussion.reload
    assert_equal 0, @discussion.tasks.count
  end

  test "correctly sets remind_at" do
    @member.update(time_zone: "Pacific/Auckland")
    rich_text = "<li data-uid='123' data-type='taskItem' data-due-on='2022-05-02' data-remind='1'>this is a task</li>"
    tasks_data = TaskService.parse_tasks(rich_text, @member)
    TaskService.update_model(@discussion, tasks_data)
    expected_remind_at = "2022-05-02 06:00".in_time_zone("Pacific/Auckland") - 1.day
    assert_equal expected_remind_at.utc.iso8601, @discussion.tasks.first.remind_at.iso8601
  end

  test "sends an email to assigned users" do
    @member.update(time_zone: "Pacific/Auckland")
    rich_text = "<li data-uid='123' data-type='taskItem' data-due-on='2022-05-02' data-remind='1'>this is a task for <span data-mention-id='#{@member.username}'>#{@member.name}</span></li>"
    tasks_data = TaskService.parse_tasks(rich_text, @member)
    TaskService.update_model(@discussion, tasks_data)
    expected_remind_at = "2022-05-02 06:00".in_time_zone("Pacific/Auckland") - 1.day

    assert_difference 'ActionMailer::Base.deliveries.count', 1 do
      TaskService.send_task_reminders(expected_remind_at.utc)
    end

    last_email = ActionMailer::Base.deliveries.last
    assert_includes last_email.to, @member.email
  end
end
