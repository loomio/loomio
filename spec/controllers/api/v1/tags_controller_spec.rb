require 'rails_helper'

describe API::V1::TagsController, type: :controller do

  let(:user) { create :user }
  let(:group) { create :group }
  let(:subgroup) { create :group, parent: group }
  let!(:discussion) { create :discussion, group: group, tags: ['apple', 'banana'] }
  let!(:poll) { create :poll, group: group, tags: ['apple', 'banana'] }
  let!(:sub_discussion) { create :discussion, group: subgroup, tags: ['apple', 'banana'] }
  let!(:sub_poll) { create :poll, group: subgroup, tags: ['apple', 'banana'] }

  let(:other_group) { create :group }
  let!(:other_discussion) { create :discussion, group: other_group, tags: ['apple', 'banana'] }
  let!(:other_poll) { create :poll, group: other_group, tags: ['apple', 'banana'] }

  before do
    TagService.update_group_tags(subgroup.id)
    TagService.update_group_and_org_tags(group.id)
    TagService.update_group_and_org_tags(other_group.id)
    group.add_admin! user
    sign_in user
  end

  describe 'create' do
    it 'creates a new tag' do
      post :create, params: {tag: {name: 'newtag', color: '#ccc', group_id: group.id}}
      expect(response.status).to eq 200
      tag = JSON.parse(response.body)['tags'].find {|t| t['name'] == 'newtag'}
      expect(tag['group_id']).to eq group.id
      expect(tag['color']).to eq '#ccc'
      expect(tag['taggings_count']).to eq 0
      expect(tag['org_taggings_count']).to eq 0
    end
  end

  describe 'update' do
    it 'updates a tag' do
      tag = Tag.find_by(group_id: group.id, name: 'apple')
      put :update, params: {id: tag.id, tag: {name: 'apple2', color: '#aaa'}}
      expect(response.status).to eq 200
      tag_attrs = JSON.parse(response.body)['tags'][0]
      expect(tag_attrs['name']).to eq 'apple2'
      expect(tag_attrs['group_id']).to eq group.id
      expect(tag_attrs['color']).to eq '#aaa'
      expect(tag_attrs['taggings_count']).to eq 2
      expect(tag_attrs['org_taggings_count']).to eq 4
    end

    it 'update parent tag updates subgroup tag' do
      tag = Tag.find_by(group_id: group.id, name: 'apple')
      put :update, params: {id: tag.id, tag: {name: 'apple2', color: '#aaa'}}
      expect(response.status).to eq 200
      expect(discussion.reload.tags).to eq ['apple2', 'banana']
      expect(sub_discussion.reload.tags).to eq ['apple2', 'banana']
      expect(poll.reload.tags).to eq ['apple2', 'banana']
      expect(sub_poll.reload.tags).to eq ['apple2', 'banana']
      expect(Tag.where(group_id: group.parent_or_self.id_and_subgroup_ids).count).to eq 4
    end

    it 'merge parent tag into existing tag' do
      tag = Tag.find_by(group_id: group.id, name: 'apple')
      put :update, params: {id: tag.id, tag: {name: 'banana', color: '#aaa'}}
      expect(response.status).to eq 200
      expect(discussion.reload.tags).to eq ['banana']
      expect(sub_discussion.reload.tags).to eq ['banana']
      expect(poll.reload.tags).to eq ['banana']
      expect(sub_poll.reload.tags).to eq ['banana']
      expect(Tag.where(group_id: group.parent_or_self.id_and_subgroup_ids).count).to eq 2
    end

    it 'update subgroup tag does not update parent tag' do
      tag = Tag.find_by(group_id: subgroup.id, name: 'apple')
      put :update, params: {id: tag.id, tag: {name: 'apple2', color: '#aaa'}}
      expect(response.status).to eq 200
      expect(discussion.reload.tags).to eq ['apple', 'banana']
      expect(sub_discussion.reload.tags).to eq ['apple2', 'banana']
      expect(poll.reload.tags).to eq ['apple', 'banana']
      expect(sub_poll.reload.tags).to eq ['apple2', 'banana']
      expect(Tag.find_by(group_id: group.id, name: 'apple').taggings_count).to eq 2
      expect(Tag.find_by(group_id: group.id, name: 'apple').org_taggings_count).to eq 2
      expect(Tag.find_by(group_id: group.id, name: 'apple2').org_taggings_count).to eq 2
      expect(Tag.find_by(group_id: subgroup.id, name: 'apple2').taggings_count).to eq 2
    end

    it 'merge subgroup tag' do
      tag = Tag.find_by(group_id: subgroup.id, name: 'apple')
      put :update, params: {id: tag.id, tag: {name: 'banana', color: '#aaa'}}
      expect(discussion.reload.tags).to eq ['apple', 'banana']
      expect(sub_discussion.reload.tags).to eq ['banana']
      expect(poll.reload.tags).to eq ['apple', 'banana']
      expect(sub_poll.reload.tags).to eq ['banana']
      expect(Tag.where(group_id: group.parent_or_self.id_and_subgroup_ids).count).to eq 3
    end
  end
end
