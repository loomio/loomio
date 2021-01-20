require 'rails_helper'

describe API::B1::PollsController do
  let(:group) { create :group }
  let(:bad_group) { create :group }
  let(:admin) { group.admins.first }

  describe 'create' do
    it 'happy case' do
      webhook = Webhook.create(
        group_id: group.id,
        author_id: group.admins.first.id,
        name: 'group admin bot',
        permissions: ['create_poll']
      )
      post :create, params: { title: 'test', poll_type: 'proposal', options: ['agree', 'disagree'], api_key: webhook.token }
      expect(response.status).to eq 200
      json = JSON.parse response.body
      discussion = json['polls'][0]
      expect(discussion['id']).to be_present
      expect(discussion['group_id']).to eq group.id
      expect(discussion['title']).to eq 'test'
    end

    it 'missing permission' do
      webhook = Webhook.create(
        group_id: group.id,
        author_id: group.admins.first.id,
        name: 'group admin bot',
        permissions: []
      )
      post :create, params: { title: 'test', api_key: webhook.token }
      expect(response.status).to eq 403
    end

    it 'incorrect key' do
      webhook = Webhook.create(
        group_id: group.id,
        author_id: group.admins.first.id,
        name: 'group admin bot',
        permissions: ['create_discussion']
      )
      post :create, params: { title: 'test', api_key: 1234 }
      expect(response.status).to eq 403
    end
  end
end
