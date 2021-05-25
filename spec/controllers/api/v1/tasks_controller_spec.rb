require 'rails_helper'

describe API::V1::TasksController, type: :controller do

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
end
