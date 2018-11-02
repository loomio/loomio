require 'rails_helper'

describe ::API::TagsController, type: :controller do

  let(:user) { create :user }
  let(:group) { create :formal_group }
  let!(:tag) { create :tag, group: group }
  let!(:another_tag) { create :tag, group: create(:formal_group, is_visible_to_public: false) }

  describe 'show' do
    before { sign_in user }

    it 'returns a specified tag' do
      group.add_member! user
      get :show, params: { id: tag.id }
      json = JSON.parse(response.body)

      tag_ids = json['tags'].map { |t| t['id'] }
      group_ids = json['groups'].map { |g| g['id'] }

      expect(tag_ids).to include tag.id
      expect(tag_ids).to_not include another_tag.id
      expect(group_ids).to include group.id
    end

    it 'does not return a tag for a group the user is not a member of' do
      get :show, params: { id: another_tag.id}
      expect(response.status).to eq 403
    end
  end

  describe 'index' do
    before { sign_in user }

    it 'returns tags from a particular group' do
      group.add_member! user
      get :index, params: { group_id: group.id }
      expect(response.status).to eq 200

      json = JSON.parse(response.body)
      tag_ids = json['tags'].map { |t| t['id'] }
      expect(tag_ids).to include tag.id
      expect(tag_ids).to_not include another_tag.id
    end

    it 'does not return tags from groups the user does not have access to' do
      get :index, params: { group_id: group.id }
      expect(response.status).to eq 200

      json = JSON.parse(response.body)
      tag_ids = json['tags'].map { |t| t['id'] }
      expect(tag_ids).to_not include tag.id
      expect(tag_ids).to_not include another_tag.id
    end

    it 'requires a group id' do
      get :index
      expect(response.status).to eq 404
    end
  end

end
