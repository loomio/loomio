require 'test_helper'

class TaskServiceTest < ActiveSupport::TestCase
  inline_jobs "sends an email to assigned users"
  setup do
    @member = users(:user)
    @member.update(username: 'sam', name: 'Sam Sammy')
    @group = groups(:group)
    @discussion = discussions(:discussion)
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

  test "rewrites duplicate task ids while preserving other task items" do
    rich_text = <<~HTML
      <li data-uid='123' data-type='taskItem'>First task</li>
      <li data-uid='123' data-type='taskItem'>Copied task</li>
      <li data-uid='456' data-type='taskItem'>Other task</li>
    HTML

    rewritten = TaskService.stub(:rand, 0.5) { TaskService.rewrite_uids(rich_text) }
    tasks = TaskService.parse_tasks(rewritten, @member)

    assert_equal ['First task', 'Copied task', 'Other task'], tasks.map { |task| task[:name] }
    assert_equal 123, tasks.first[:uid]
    assert_equal 456, tasks.last[:uid]
    assert_equal 3, tasks.map { |task| task[:uid] }.uniq.length
    assert_operator tasks.second[:uid], :>, 0
    assert_operator tasks.second[:uid], :<, 100_000_000
  end

  test "creates a task" do
    rich_text = "<li data-uid='123' data-type='taskItem' data-checked='true' data-author-id='#{@member.id}' data-due-on='2022-05-02'>this is a task for <span data-mention-id='#{@member.username}'>#{@member.name}</span></li>"
    tasks_data = TaskService.parse_tasks(rich_text, @member)
    freeze_time do
      TaskService.update_model(@discussion, tasks_data)
      assert_equal Time.current, @discussion.tasks.sole.done_at
    end

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

    done_at = task.done_at
    travel 1.hour do
      TaskService.update_model(@discussion, tasks_data)

      assert_equal done_at, task.reload.done_at
    end
  end

  test "editing an incomplete task leaves its completion timestamp empty" do
    rich_text = "<li data-uid='123' data-type='taskItem' data-checked='false'>Original task</li>"
    tasks_data = TaskService.parse_tasks(rich_text, @member)
    TaskService.update_model(@discussion, tasks_data)
    task = @discussion.tasks.sole

    tasks_data.first[:name] = 'Edited task'
    TaskService.update_model(@discussion, tasks_data)

    assert_equal 'Edited task', task.reload.name
    assert_not task.done
    assert_nil task.done_at
  end

  test "updating tasks preserves authors who can access group and direct topics" do
    [topics(:discussion_topic), topics(:direct_topic)].each do |topic|
      author = users(:guest_normal)
      rich_text = "<li data-uid='123' data-type='taskItem' data-author-id='#{author.id}'>Original task</li>"
      tasks_data = TaskService.parse_tasks(rich_text, author)
      TaskService.update_model(topic.topicable, tasks_data)
      task = topic.topicable.tasks.sole

      tasks_data.first[:name] = 'Edited task'
      TaskService.update_model(topic.topicable, tasks_data)

      assert_equal 'Edited task', task.reload.name
      assert_equal author, task.author
    end
  end

  test "updating tasks falls back to the record author for users without topic access" do
    [topics(:discussion_topic), topics(:direct_topic)].each do |topic|
      rich_text = "<li data-uid='123' data-type='taskItem'>Task</li>"
      tasks_data = TaskService.parse_tasks(rich_text, topic.topicable.author)
      TaskService.update_model(topic.topicable, tasks_data)
      task = topic.topicable.tasks.sole

      %i[alien_quiet former_guest_loud former_member_loud inactive_guest_loud inactive_member_loud non_guest_loud].each do |fixture|
        user = users(fixture)
        tasks_data.first[:author_id] = user.id
        TaskService.update_model(topic.topicable, tasks_data)

        assert_equal topic.topicable.author, task.reload.author
      end
    end
  end

  test "completing a task persists its doer timestamp and matching checkbox" do
    @discussion.update!(description: <<~HTML)
      <li data-uid='123' data-type='taskItem' data-checked='false'>First task</li>
      <li data-uid='456' data-type='taskItem' data-checked='false'>Other task</li>
    HTML
    task = @discussion.tasks.find_by!(uid: 123)

    freeze_time do
      TaskService.update_done(task, @member, true)

      assert task.done
      assert task.reload.done
      assert_equal @member, task.doer
      assert_equal Time.current, task.done_at
      document = Nokogiri::HTML.fragment(@discussion.reload.description)
      assert_equal 'true', document.at_css("li[data-uid='123']")['data-checked']
      assert_equal 'false', document.at_css("li[data-uid='456']")['data-checked']
    end
  end

  test "reopening a task clears its doer timestamp and checkbox" do
    @discussion.update!(description: "<li data-uid='123' data-type='taskItem' data-checked='false'>Task</li>")
    task = @discussion.tasks.sole
    TaskService.update_done(task, @member, true)

    TaskService.update_done(task, @member, false)

    assert_not task.done
    assert_not task.reload.done
    assert_nil task.doer
    assert_nil task.done_at
    document = Nokogiri::HTML.fragment(@discussion.reload.description)
    assert_equal 'false', document.at_css("li[data-uid='123']")['data-checked']
  end

  test "task updates are published to the group and current guests of group and direct topics" do
    [topics(:discussion_topic), topics(:direct_topic)].each do |topic|
      record = topic.topicable
      record.update!(description: "<li data-uid='123' data-type='taskItem' data-checked='false'>Task</li>")
      publications = []
      publish = lambda do |models, group_id: nil, user_id: nil|
        publications << { models: models, group_id: group_id, user_id: user_id }
      end

      MessageChannelService.stub(:publish_models, publish) do
        TaskService.update_done(record.tasks.sole, record.author, true)
      end

      assert_equal topic.group_id ? [topic.group_id] : [], publications.filter_map { |publication| publication[:group_id] }
      guest_fixtures = %i[guest_quiet guest_normal guest_admin_normal guest_loud]
      if topic.group_id
        # This former member was granted guest access after membership was revoked.
        membership = memberships(:former_member_guest_membership)
        reader = topic_readers(:former_member_guest_reader)
        assert_operator reader.created_at, :>, membership.revoked_at
        guest_fixtures << :former_member_guest
      end
      guest_ids = guest_fixtures.map { |fixture| users(fixture).id }
      assert_equal guest_ids.sort, publications.filter_map { |publication| publication[:user_id] }.sort
      assert publications.all? { |publication| publication[:models] == [record] }
    end
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

  test "creating a discussion with task items in the description does not raise a SQL error" do
    # Regression: LOOMIO-COM-2AQ
    # When creating a new discussion, Discussion belongs_to a new Topic, and Topic belongs_to
    # topicable (the Discussion). Rails autosaves both, creating a circular save chain where
    # Discussion's after_save fires before Topic is persisted, making topic.id nil.
    # topic.members then builds invalid SQL: "topic_id = AND" → PG::SyntaxError.
    task_body = "<li data-uid='999' data-type='taskItem' data-checked='false' data-author-id='#{@member.id}'>do the thing</li>"

    discussion = nil
    assert_nothing_raised do
      discussion = DiscussionService.create(params: {
        title:              'Discussion with tasks',
        description:        task_body,
        description_format: 'html',
        group_id:           @group.id,
        private:            true
      }, actor: @member)
    end

    assert discussion.persisted?
    assert discussion.topic.persisted?
  end

  test "materializes template task items only after creating a discussion" do
    description = "<li data-uid='123' data-type='taskItem' data-checked='false'>do the thing</li>"
    template = DiscussionTemplate.create!(
      group: @group,
      process_name: "Task template",
      process_subtitle: "subtitle",
      description: description
    )

    assert_empty template.tasks

    discussion = DiscussionService.create(params: {
      title: "Discussion from task template",
      description: template.description,
      description_format: template.description_format,
      discussion_template_id: template.id,
      group_id: @group.id,
      private: true
    }, actor: @member)

    task = discussion.tasks.sole
    assert_equal "do the thing", task.name
    assert_equal @member, task.author
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
