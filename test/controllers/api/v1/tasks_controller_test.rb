require 'test_helper'
require_relative '../../../support/access_volume_matrix'

class Api::V1::TasksControllerTest < ActionController::TestCase
  setup do
    @author = User.find_or_create_by!(email: "taskauthor@example.com") do |u|
      u.name = "author"
      u.username = "taskauthor"
      u.password_digest = "$2a$12$K3E5h0VGlqmXL8HqWw7mIe3qP0XjQSfZ1jK4PqYX7Qq5N9YK6L4/K"
      u.email_verified = true
    end

    @doer = User.find_or_create_by!(email: "taskdoer@example.com") do |u|
      u.name = "doer"
      u.username = "taskdoer"
      u.password_digest = "$2a$12$K3E5h0VGlqmXL8HqWw7mIe3qP0XjQSfZ1jK4PqYX7Qq5N9YK6L4/K"
      u.email_verified = true
    end

    @group = groups(:group)
    @group.add_admin! @author
    @group.add_member! @doer

    @discussion = DiscussionService.create(params: { title: "Tasks #{SecureRandom.hex(4)}", group_id: @group.id }, actor: @author)
    @discussion.description_format = 'html'
    @discussion.description = "<ul data-type='taskList'>
  <li data-uid='17688090' data-checked='false' data-author-id='#{@author.id}' data-type='taskItem'>
    <p><span class='mention' data-mention-id='#{@doer.username}'>@#{@doer.name}</span> do the dishes before 2021-06-01</p>
  </li>
</ul>"
    @discussion.save

    sign_in @doer
  end

  test "fetch tasks" do
    get :index
    assert_response :success

    tasks = JSON.parse(response.body)['tasks']
    assert_equal 17688090, tasks[0]['uid']
    assert_equal 1, tasks.size
  end

  test "index includes the containing topic needed to label comment tasks" do
    comment = comments(:public_discussion_comment)
    Task.create!(
      record: comment,
      author: @doer,
      doer: @doer,
      done: false,
      name: "Follow up on the comment",
      uid: "comment-task"
    )

    get :index

    assert_response :success
    body = JSON.parse(response.body)
    assert_includes body.fetch("comments").map { |record| record.fetch("id") }, comment.id
    assert_includes body.fetch("topics").map { |record| record.fetch("id") }, comment.topic_id
  end

  test "does not fetch tasks when record access is revoked" do
    Membership.where(group_id: @group.id, user_id: @doer.id).update_all(revoked_at: Time.current)
    @doer.reload
    sign_in @doer

    get :index
    assert_response :success

    tasks = JSON.parse(response.body)['tasks']
    assert_empty tasks
  end

  test "mark_as_done" do
    task = @discussion.tasks.first
    post :mark_as_done, params: { id: task.id }
    assert_response :success

    tasks = JSON.parse(response.body)['tasks']
    assert_equal task.id, tasks[0]['id']
    assert tasks[0]['done']
    assert_not_nil tasks[0]['done_at']
    assert_equal 1, tasks.size

    doc = Nokogiri::HTML::DocumentFragment.parse(@discussion.reload.description)
    li = doc.css("li[data-uid='#{tasks[0]['uid']}']").first
    assert_equal 'true', li['data-checked']
  end

  test "cannot mark task done when record access is revoked" do
    task = @discussion.tasks.first
    Membership.where(group_id: @group.id, user_id: @doer.id).update_all(revoked_at: Time.current)
    @doer.reload
    sign_in @doer

    post :mark_as_done, params: { id: task.id }
    assert_response :forbidden

    doc = Nokogiri::HTML::DocumentFragment.parse(@discussion.reload.description)
    li = doc.css("li[data-uid='#{task.uid}']").first
    assert_equal 'false', li['data-checked']
  end

  test "update_done true" do
    task = @discussion.tasks.first
    post :update_done, params: { discussion_id: @discussion.id, uid: task.uid, done: 'true' }
    assert_response :success

    tasks = JSON.parse(response.body)['tasks']
    assert_equal task.id, tasks[0]['id']
    assert tasks[0]['done']
    assert_not_nil tasks[0]['done_at']
    assert_equal 1, tasks.size

    doc = Nokogiri::HTML::DocumentFragment.parse(@discussion.reload.description)
    li = doc.css("li[data-uid='#{tasks[0]['uid']}']").first
    assert_equal 'true', li['data-checked']
  end

  test "update_done false" do
    task = @discussion.tasks.first
    post :update_done, params: { discussion_id: @discussion.id, uid: task.uid, done: 'false' }
    assert_response :success

    tasks = JSON.parse(response.body)['tasks']
    assert_equal task.id, tasks[0]['id']
    refute tasks[0]['done']
    assert_nil tasks[0]['done_at']
    assert_equal 1, tasks.size

    doc = Nokogiri::HTML::DocumentFragment.parse(@discussion.reload.description)
    li = doc.css("li[data-uid='#{tasks[0]['uid']}']").first
    assert_equal 'false', li['data-checked']
  end

  test "mark_as_not_done" do
    task = @discussion.tasks.first
    post :mark_as_done, params: { id: task.id }
    assert_response :success

    post :mark_as_not_done, params: { id: task.id }
    assert_response :success

    tasks = JSON.parse(response.body)['tasks']
    assert_equal task.id, tasks[0]['id']
    refute tasks[0]['done']
    assert_nil tasks[0]['done_at']
    assert_equal 1, tasks.size

    doc = Nokogiri::HTML::DocumentFragment.parse(@discussion.reload.description)
    li = doc.css("li[data-uid='#{tasks[0]['uid']}']").first
    assert_equal 'false', li['data-checked']
  end

  test "readable but unassigned members cannot change task status through any mutation route" do
    topic = topics(:discussion_topic)
    record = topic.topicable
    owner = users(:user)
    viewer = users(:member_normal)
    topic.group.update!(members_can_edit_discussions: false)
    record.update!(description_format: 'html', description: task_list_html(93001, owner))
    task = record.tasks.find_by!(uid: 93001)
    assert viewer.can?(:show, record)
    assert_not viewer.can?(:update, task)
    sign_in viewer

    {
      update_done: { discussion_id: record.id, uid: task.uid, done: 'true' },
      mark_as_done: { id: task.id },
      mark_as_not_done: { id: task.id }
    }.each do |action, params|
      TaskService.update_done(task, owner, action == :mark_as_not_done)
      before = task.reload.attributes
      body = record.reload.body

      post action, params: params

      assert_response :forbidden, action.to_s
      assert_equal before, task.reload.attributes, action.to_s
      assert_equal body, record.reload.body, action.to_s
    end
  end

  test "task lists distinguish authors doers assignees and unrelated topic readers" do
    topic = topics(:discussion_topic)
    record = topic.topicable
    owner = users(:user)
    doer = users(:member_normal)
    assignee = users(:guest_normal)
    topic.group.update!(members_can_edit_discussions: true)
    record.update!(description_format: 'html', description: task_list_html(93003, owner, assignee: assignee))
    task = record.tasks.find_by!(uid: 93003)
    assert doer.can?(:update, task)
    TaskService.update_done(task, doer, true)
    assert_equal owner.id, task.reload.author_id
    assert_equal doer.id, task.doer_id
    assert_equal [assignee.id], task.users.pluck(:id)
    related_ids = [owner.id, doer.id, assignee.id]

    (AccessVolumeMatrix::ROLES.map { |role| users(role) } + [users(:server_admin)]).each do |actor|
      expected = related_ids.include?(actor.id)
      assert_equal expected, actor.can?(:show, task), actor.email
      sign_in actor

      get :index

      assert_response :success
      assert_equal expected, response.parsed_body.fetch('tasks').any? { |item| item['id'] == task.id }, actor.email
    end

    topic.group.update!(members_can_edit_discussions: false)
    assert assignee.can?(:update, Task.find(task.id))
  end

  test "update_done resolves comment poll and outcome tasks independently when their UIDs match" do
    actor = users(:member_normal)
    topic = topics(:discussion_topic)
    topic.update!(polls_one_at_a_time: false)
    html = task_list_html(93002, actor)
    comment = CommentService.create(comment: Comment.new(parent: topic.topicable, body: html, body_format: 'html'), actor: actor)
    poll = PollService.create(params: {
      topic_id: topic.id, title: 'Task record routing', poll_type: 'proposal',
      details: html, details_format: 'html', poll_option_names: %w[Agree Disagree], closing_at: 1.day.from_now
    }, actor: actor)
    PollService.close(poll: poll, actor: actor)
    outcome = OutcomeService.create(outcome: Outcome.new(poll: poll, statement: html, statement_format: 'html'), actor: actor)
    sign_in actor

    [comment, poll, outcome].each do |record|
      task = record.tasks.find_by!(uid: 93002)
      params = { "#{record.class.name.underscore}_id" => record.id, uid: task.uid, done: 'true' }

      post :update_done, params: params

      assert_response :success
      assert_equal [task.id], response.parsed_body.fetch('tasks').pluck('id')
      assert task.reload.done?
      assert_equal actor.id, task.doer_id
      checkbox = Nokogiri::HTML::DocumentFragment.parse(record.reload.body).at_css("li[data-uid='93002']")
      assert_equal 'true', checkbox['data-checked']
    end
  end

  private

  def task_list_html(uid, author, assignee: nil)
    content = assignee ? "<span class='mention' data-mention-id='#{assignee.username}'>@#{assignee.name}</span> Follow up" : 'Follow up'
    "<ul data-type='taskList'><li data-uid='#{uid}' data-checked='false' data-author-id='#{author.id}' data-type='taskItem'><p>#{content}</p></li></ul>"
  end
end
