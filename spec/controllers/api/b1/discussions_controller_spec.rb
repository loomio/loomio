require 'rails_helper'

describe API::B1::DiscussionsController do
  let(:group) { create :group }
  let(:admin) { group.admins.first }

  describe 'create' do
    it 'happy case' do
      bot = User.create!(name: 'bot user', email: 'bot@example.com', email_verified: false)
      webhook = Webhook.create(
        group_id: group.id,
        actor_id: bot.id,
        author_id: group.admins.first.id,
        name: 'group admin bot',
        permissions: ['create_discussion']
      )
      post :create, params: { title: 'test', group_id: group.id, api_key: webhook.token }
      expect(response.status).to eq 200
      json = JSON.parse response.body
      discussion = json['discussions'][0]
      expect(discussion['id']).to be_present
      expect(discussion['group_id']).to eq group.id
      expect(discussion['title']).to eq 'test'
    end

    it 'missing permission' do
      bot = User.create!(name: 'bot user', email: 'bot@example.com', email_verified: false)
      webhook = Webhook.create(
        group_id: group.id,
        actor_id: bot.id,
        author_id: group.admins.first.id,
        name: 'group admin bot',
        permissions: []
      )
      post :create, params: { title: 'test', group_id: group.id, api_key: webhook.token }
      expect(response.status).to eq 403
    end

    it 'incorrect key' do
      Webhook.create(
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
