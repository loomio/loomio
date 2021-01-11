require 'rails_helper'

describe API::B1::DiscussionsController do
  let(:group) { create :group }
  let(:admin) { group.admins.first }

  describe 'create' do
    it 'happy case' do
      i = Integration.create(
        group_id: group.id,
        actor_id: group.admins.first.id,
        author_id: group.admins.first.id,
        name: 'group admin bot',
        permissions: ['create_discussion']
      )
      post :create, params: { title: 'test', api_key: i.token }
      expect(response.status).to eq 200
      json = JSON.parse response.body
      expect(json['discussion']['id']).to be_present
      expect(json['discussion']['group_id']).to eq group.id
      expect(json['discussion']['title']).to eq 'test'
    end

    it 'missing permission' do
      Integration.create(
        group_id: group.id,
        actor_id: group.admins.first.id,
        author_id: group.admins.first.id,
        name: 'group admin bot'
      )
      post :create, params: { title: 'test', group_id: group.id, api_key: 1234 }
      expect(response.status).to eq 403
    end

    it 'incorrect key' do
      Integration.create(
        group_id: group.id,
        actor_id: group.admins.first.id,
        author_id: group.admins.first.id,
        name: 'group admin bot'
      )
      post :create, params: { title: 'test', group_id: group.id, api_key: 1234 }
      expect(response.status).to eq 403
    end
  end
end
