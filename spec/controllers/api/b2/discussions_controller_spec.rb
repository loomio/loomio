require 'rails_helper'

describe API::B2::DiscussionsController do
  let(:group) { create :group }
  let(:bad_group) { create :group }
  let(:user) { group.admins.first }

  describe 'create' do
    it 'happy case' do
      user.update(api_key: 'abc123')
      post :create, params: { title: 'test', group_id: group.id, api_key: user.api_key }
      expect(response.status).to eq 200
      json = JSON.parse response.body
      discussion = json['discussions'][0]
      expect(discussion['id']).to be_present
      expect(discussion['group_id']).to eq group.id
      expect(discussion['title']).to eq 'test'
    end

    it 'happy case notify group' do
      user.update(api_key: 'abc123')
      post :create, params: { title: 'test', group_id: group.id, api_key: user.api_key, recipient_audience: 'group' }
      expect(response.status).to eq 200
      json = JSON.parse response.body
      discussion = json['discussions'][0]
      expect(discussion['id']).to be_present
      expect(discussion['group_id']).to eq group.id
      expect(discussion['title']).to eq 'test'
      expect(Discussion.find(discussion['id']).readers.count).to eq group.members.humans.count
    end

    it 'missing permission - archived' do
      Membership.where(group_id: group.id, user_id: user.id).update(archived_at: Time.now)
      post :create, params: { title: 'test', group_id: group.id, api_key: user.api_key }
      expect(response.status).to eq 403
    end

    it 'missing permission - deleted' do
      Membership.where(group_id: group.id, user_id: user.id).delete_all
      post :create, params: { title: 'test', group_id: group.id, api_key: user.api_key }
      expect(response.status).to eq 403
    end

    it 'incorrect key' do
      post :create, params: { title: 'test', group_id: group.id, api_key: 1234 }
      expect(response.status).to eq 403
    end

    it 'blank key' do
      post :create, params: { title: 'test', group_id: group.id }
      expect(response.status).to eq 403
    end
  end
end
