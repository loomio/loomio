require 'rails_helper'

describe API::V1::TagsController, type: :controller do

  let(:user) { create :user }
  let(:group) { create :group }
  let(:subgroup) { create :group, parent: group }
  let!(:discussion) { create :discussion, group: group, tags: ['apple', 'banana'] }
  let!(:poll) { create :poll, group: group, tags: ['apple', 'banana'] }
  let!(:sub_discussion) { create :discussion, group: subgroup, tags: ['apple', 'banana'] }
  let!(:sub_poll) { create :poll, group: group, tags: ['apple', 'banana'] }

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
      TagService.update_group_and_org_tags(group.id)
    end

    it 'updates a tag' do
      tag = Tag.find_by(group_id: group.id, name: 'apple')
      put :update, params: {id: tag.id, tag: {name: 'apple2', color: '#aaa'}}
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['tags'][0]['name']).to eq 'apple2'
      expect(JSON.parse(response.body)['tags'][0]['group_id']).to eq group.id
      expect(JSON.parse(response.body)['tags'][0]['color']).to eq '#aaa'
      expect(discussion.reload.tags).to eq ['apple2', 'banana']
      expect(sub_discussion.reload.tags).to eq ['apple2', 'banana']
      expect(poll.reload.tags).to eq ['apple2', 'banana']
      expect(sub_poll.reload.tags).to eq ['apple2', 'banana']
      expect(Tag.where(group_id: group.parent_or_self.id_and_subgroup_ids).count).to eq 4
    end
  end
end
