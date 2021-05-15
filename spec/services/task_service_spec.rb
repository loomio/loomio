require 'rails_helper'

describe TaskService do
  let(:model) { create :discussion }
  let(:member) { create :user, username: 'sam', name: 'Sam Sammy' }

  before do
    model.group.add_member! member
  end

  it 'parses a simple task from some html' do
    rich_text = "<li data-uid='123' data-type='taskItem' data-checked='false' data-author-id='1'>this is a task</li>"
    tasks_data = TaskService.parse_tasks(rich_text)
    expect(tasks_data.size).to eq 1
    expect(tasks_data.first[:uid]).to eq 123
    expect(tasks_data.first[:name]).to eq "this is a task"
    expect(tasks_data.first[:due_on]).to eq nil
    expect(tasks_data.first[:usernames]).to be_empty
    expect(tasks_data.first[:done]).to eq false
    expect(tasks_data.first[:author_id]).to eq 1
  end

  it 'parses a complex task from some html' do
    rich_text = "<li data-uid='123' data-type='taskItem' data-checked='true' data-author-id='1'>this is a task for <span data-mention-id='#{member.username}'>#{member.name}</span> due 2022-05-02</li>"
    tasks_data = TaskService.parse_tasks(rich_text)
    expect(tasks_data.size).to eq 1
    expect(tasks_data.first[:uid]).to eq 123
    expect(tasks_data.first[:name]).to eq "this is a task for Sam Sammy due 2022-05-02"
    expect(tasks_data.first[:due_on]).to eq Date.parse("2022-05-02")
    expect(tasks_data.first[:usernames]).to include 'sam'
    expect(tasks_data.first[:done]).to eq true
    expect(tasks_data.first[:author_id]).to eq 1
  end

  it 'creates a task' do
    rich_text = "<li data-uid='123' data-type='taskItem' data-checked='true' data-author-id='#{member.id}'>this is a task for <span data-mention-id='#{member.username}'>#{member.name}</span> due 2022-05-02</li>"
    tasks_data = TaskService.parse_tasks(rich_text)
    TaskService.update_model(model, tasks_data)
    expect(model.tasks.count).to eq 1
    expect(model.tasks.first.uid).to eq 123
    expect(model.tasks.first.name).to eq "this is a task for Sam Sammy due 2022-05-02"
    expect(model.tasks.first.due_on).to eq Date.parse("2022-05-02")
    expect(model.tasks.first.users).to include member
    expect(model.tasks.first.done).to eq true
    expect(model.tasks.first.author).to eq member
  end

  it 'updates a task' do
    rich_text = "<li data-uid='123' data-type='taskItem' data-checked='false' data-author-id='#{member.id}'>this is a task due 2022-05-02</li>"
    tasks_data = TaskService.parse_tasks(rich_text)
    TaskService.update_model(model, tasks_data)
    task = model.tasks.first

    expect(task.uid).to eq 123
    expect(task.name).to eq "this is a task due 2022-05-02"
    expect(task.due_on).to eq Date.parse("2022-05-02")
    expect(task.users).to be_empty
    expect(task.author).to eq member
    expect(task.done).to eq false
    expect(task.done_at).to be_empty

    rich_text = "<li data-uid='123' data-type='taskItem' data-checked='true' data-author-id='#{member.id}'>this is a task for <span data-mention-id='#{member.username}'>#{member.name}</span> due 2022-06-01</li>"
    tasks_data = TaskService.parse_tasks(rich_text)
    TaskService.update_model(model, tasks_data)

    task.reload

    expect(task.name).to eq "this is a task for Sam Sammy due 2022-06-01"
    expect(task.due_on).to eq Date.parse("2022-06-01")
    expect(task.users).to include member
    expect(task.done).to eq true
    expect(task.done_at).to_not be_empty
  end

  it 'destroys a task' do
    rich_text = "<li data-uid='123' data-type='taskItem'>this is a task</li>"
    tasks_data = TaskService.parse_tasks(rich_text)
    TaskService.update_model(model, tasks_data)
    expect(model.tasks.count).to eq 1

    tasks_data = TaskService.parse_tasks("")
    TaskService.update_model(model, tasks_data)
    model.reload
    expect(model.tasks.count).to eq 0
  end
end
