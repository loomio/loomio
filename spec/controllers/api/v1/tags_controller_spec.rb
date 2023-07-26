require 'rails_helper'

describe API::V1::TagsController, type: :controller do

  let(:user) { create :user }
  let(:group) { create :group }
  let(:subgroup) { create :group, parent: group }
  let!(:tag) { create :tag, name: "test", color: "#ffffff", group: group }
  let!(:another_tag) { create :tag, name: "anothertag", color: "#654321", group: create(:group, is_visible_to_public: false) }
  let!(:discussion) { create :discussion, group: group, tags: ['test', 'same'] }
  let!(:poll) { create :poll, group: group, tags: ['test', 'same'] }
  let!(:sub_discussion) { create :discussion, group: subgroup, tags: ['test', 'same'] }
  let!(:sub_poll) { create :poll, group: group, tags: ['test', 'same'] }

  describe 'create' do
    before do
      group.add_admin! user
      sign_in user
    end

    it 'creates a new tag' do
      post :create, params: {tag: {name: 'newtag', color: '#ccc', group_id: group.id}}
      expect(response.status).to eq 200
      tag = JSON.parse(response.body)['tags'].find {|t| t['name'] == 'newtag'}
      expect(tag['group_id']).to eq group.id
      expect(tag['color']).to eq '#ccc'
    end
  end

  describe 'update' do
    before do
      group.add_admin! user
      sign_in user
    end

    it 'updates a tag' do
      put :update, params: {id: tag.id, tag: {name: 'updated', color: '#ccc'}}
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['tags'][0]['name']).to eq 'updated'
      expect(JSON.parse(response.body)['tags'][0]['group_id']).to eq group.id
      expect(JSON.parse(response.body)['tags'][0]['color']).to eq '#ccc'
      expect(discussion.reload.tags).to eq ['updated', 'same']
      expect(sub_discussion.reload.tags).to eq ['updated', 'same']
      expect(poll.reload.tags).to eq ['updated', 'same']
      expect(sub_poll.reload.tags).to eq ['updated', 'same']
    end
  end
end
