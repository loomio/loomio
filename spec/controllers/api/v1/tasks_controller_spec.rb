require 'rails_helper'

describe Api::V1::TasksController, type: :controller do

  let(:author) { create :user, name: 'author' }
  let(:doer) { create :user, name: 'doer', username: 'doer' }
  let(:another_doer) { create :user, name: 'another doer', username: 'anotherdoer' }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group, author: author }

  before do
    group.add_admin! author
    group.add_member! doer

    discussion.description_format = 'html'
    discussion.description = "<ul data-type='taskList'>
  <li data-uid='17688090' data-checked='false' data-author-id='#{author.id}' data-type='taskItem'>
    <p><span class='mention' data-mention-id='#{doer.username}'>@#{doer.name}</span> do the dishes before 2021-06-01</p>
  </li>
</ul>"
    discussion.save
  end

  describe 'as doer' do
    before do
      sign_in doer
    end

    it 'fetch tasks' do
      get :index
      expect(response.status).to eq 200
      tasks = JSON.parse(response.body)['tasks']
      expect(tasks[0]['uid']).to eq 17688090
      expect(tasks.size).to eq 1
    end

    it 'mark_as_done' do
      task = discussion.tasks.first
      post :mark_as_done, params: {id: task.id}
      expect(response.status).to eq 200
      tasks = JSON.parse(response.body)['tasks']
      expect(tasks[0]['id']).to eq task.id
      expect(tasks[0]['done']).to eq true
      expect(tasks[0]['done_at']).to be_present
      expect(tasks.size).to eq 1

      doc = Nokogiri::HTML::DocumentFragment.parse(discussion.reload.description)
      li = doc.css("li[data-uid='#{tasks[0]['uid']}']").first
      expect(li['data-checked']).to eq 'true'
    end

    it 'update_done true' do
      task = discussion.tasks.first
      post :update_done, params: {discussion_id: discussion.id, uid: task.uid, done: 'true'}
      expect(response.status).to eq 200
      tasks = JSON.parse(response.body)['tasks']
      expect(tasks[0]['id']).to eq task.id
      expect(tasks[0]['done']).to eq true
      expect(tasks[0]['done_at']).to be_present
      expect(tasks.size).to eq 1

      doc = Nokogiri::HTML::DocumentFragment.parse(discussion.reload.description)
      li = doc.css("li[data-uid='#{tasks[0]['uid']}']").first
      expect(li['data-checked']).to eq 'true'
    end

    it 'update_done false' do
      task = discussion.tasks.first
      post :update_done, params: {discussion_id: discussion.id, uid: task.uid, done: 'false'}
      expect(response.status).to eq 200
      tasks = JSON.parse(response.body)['tasks']
      expect(tasks[0]['id']).to eq task.id
      expect(tasks[0]['done']).to eq false
      expect(tasks[0]['done_at']).to_not be_present
      expect(tasks.size).to eq 1

      doc = Nokogiri::HTML::DocumentFragment.parse(discussion.reload.description)
      li = doc.css("li[data-uid='#{tasks[0]['uid']}']").first
      expect(li['data-checked']).to eq 'false'
    end

    it 'mark_as_not_done' do
      task = discussion.tasks.first
      post :mark_as_done, params: {id: task.id}
      expect(response.status).to eq 200
      post :mark_as_not_done, params: {id: task.id}
      expect(response.status).to eq 200
      tasks = JSON.parse(response.body)['tasks']
      expect(tasks[0]['id']).to eq task.id
      expect(tasks[0]['done']).to eq false
      expect(tasks[0]['done_at']).to_not be_present
      expect(tasks.size).to eq 1

      doc = Nokogiri::HTML::DocumentFragment.parse(discussion.reload.description)
      li = doc.css("li[data-uid='#{tasks[0]['uid']}']").first
      expect(li['data-checked']).to eq 'false'
    end
  end

  describe 'as user' do
    let(:task) { Task.create(author_id: author.id, uid: 123, name: 'task 1', done: false) }
    let!(:extension) { TasksUsersExtension.create(task_id: task.id, user_id: author.id ) }

    before do
      sign_in author
    end

    it 'task can be hidden' do
      expect(TasksUsersExtension.find_by(task_id: task.id, user_id: author.id).hidden).to eq false
      post :mark_as_hidden, params: {id: task.id}
      expect(response.status).to eq 200
      expect(TasksUsersExtension.find_by(task_id: task.id, user_id: author.id).hidden).to eq true
    end

    it 'task can be revealed' do
      expect(TasksUsersExtension.find_by(task_id: task.id, user_id: author.id).hidden).to eq false
      post :mark_as_hidden, params: {id: task.id}
      expect(response.status).to eq 200
      expect(TasksUsersExtension.find_by(task_id: task.id, user_id: author.id).hidden).to eq true

      post :mark_as_not_hidden, params: {id: task.id}
      expect(TasksUsersExtension.find_by(task_id: task.id, user_id: author.id).hidden).to eq false
    end

    it 'returns hidden state for task' do
      get :index, params: { t: 'all'}
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['tasks'][0]['hidden']).to eq false
    end
  end
end
