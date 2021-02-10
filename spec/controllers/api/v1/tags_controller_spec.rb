require 'rails_helper'

describe API::V1::TagsController, type: :controller do

  let(:user) { create :user }
  let(:group) { create :group }
  let!(:tag) { create :tag, name: "test", color: "#ffffff", group: group }
  let!(:another_tag) { create :tag, name: "anothertag", color: "#654321", group: create(:group, is_visible_to_public: false) }

  describe 'create' do
    before do
      group.add_member! user
      sign_in user
    end

    it 'creates a new tag' do
      post :create, params: {tag: {name: 'newtag', color: '#ccc', group_id: group.id}}
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['tags'][0]['name']).to eq 'newtag'
      expect(JSON.parse(response.body)['tags'][0]['group_id']).to eq group.id
      expect(JSON.parse(response.body)['tags'][0]['color']).to eq '#ccc'
    end
  end

  describe 'update' do
    before do
      group.add_member! user
      sign_in user
    end

    it 'updates a tag' do
      put :update, params: {id: tag.id, tag: {name: 'updated', color: '#ccc'}}
      expect(response.status).to eq 200
      expect(JSON.parse(response.body)['tags'][0]['name']).to eq 'updated'
      expect(JSON.parse(response.body)['tags'][0]['group_id']).to eq group.id
      expect(JSON.parse(response.body)['tags'][0]['color']).to eq '#ccc'
    end
  end

  # describe 'show' do
  #   before { sign_in user }
  #
  #   it 'returns a specified tag' do
  #     group.add_member! user
  #     get :show, params: { id: tag.id }
  #     json = JSON.parse(response.body)
  #
  #     tag_ids = json['tags'].map { |t| t['id'] }
  #     # group_ids = json['groups'].map { |g| g['id'] }
  #
  #     expect(tag_ids).to include tag.id
  #     expect(tag_ids).to_not include another_tag.id
  #     # expect(group_ids).to include group.id
  #   end
  #
  #   it 'does not return a tag for a group the user is not a member of' do
  #     get :show, params: { id: another_tag.id}
  #     expect(response.status).to eq 403
  #   end
  # end

  # describe 'index' do
  #   before { sign_in user }
  #
  #   it 'returns tags from a particular group' do
  #     group.add_member! user
  #     get :index, params: { group_id: group.id }
  #     expect(response.status).to eq 200
  #
  #     json = JSON.parse(response.body)
  #     tag_ids = json['tags'].map { |t| t['id'] }
  #     expect(tag_ids).to include tag.id
  #     expect(tag_ids).to_not include another_tag.id
  #   end
  #
  #   it 'does not return tags from groups the user does not have access to' do
  #     get :index, params: { group_id: group.id }
  #     expect(response.status).to eq 200
  #
  #     json = JSON.parse(response.body)
  #     tag_ids = json['tags'].map { |t| t['id'] }
  #     expect(tag_ids).to_not include tag.id
  #     expect(tag_ids).to_not include another_tag.id
  #   end
  #
  #   it 'requires a group id' do
  #     get :index
  #     expect(response.status).to eq 404
  #   end
  # end

end
