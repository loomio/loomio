require 'test_helper'

class Api::V1::TasksControllerTest < ActionController::TestCase
  setup do
    @author = User.find_or_create_by!(email: "taskauthor@example.com") do |u|
      u.name = "author"
      u.username = "taskauthor"
      u.encrypted_password = "$2a$12$K3E5h0VGlqmXL8HqWw7mIe3qP0XjQSfZ1jK4PqYX7Qq5N9YK6L4/K"
      u.email_verified = true
    end
    
    @doer = User.find_or_create_by!(email: "taskdoer@example.com") do |u|
      u.name = "doer"
      u.username = "taskdoer"
      u.encrypted_password = "$2a$12$K3E5h0VGlqmXL8HqWw7mIe3qP0XjQSfZ1jK4PqYX7Qq5N9YK6L4/K"
      u.email_verified = true
    end
    
    @group = groups(:test_group)
    @group.add_admin! @author
    @group.add_member! @doer
    
    @discussion = create_discussion(group: @group, author: @author)
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
end
