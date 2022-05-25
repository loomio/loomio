require 'rails_helper'

describe API::B1::MembershipsController do
  let(:group) { create :group }
  let(:bad_group) { create :group }
  let(:admin) { group.admins.first }

  describe 'create' do
    it 'adds members to group' do
      webhook = Webhook.create(
        group_id: group.id,
        author_id: group.admins.first.id,
        name: 'bot',
        permissions: ['manage_memberships']
      )
      post :create, params: { emails: ['hey@there.com'], api_key: webhook.token }
      expect(response.status).to eq 200
      json = JSON.parse response.body
      expect(json['added_emails']).to eq ['hey@there.com']
      expect(json['removed_emails']).to eq []
    end

    it 'removes members from group' do
      webhook = Webhook.create(
        group_id: group.id,
        author_id: group.admins.first.id,
        name: 'bot',
        permissions: ['manage_memberships']
      )
      existing_email = group.admins.first.email
      post :create, params: { remove_absent: 1, emails: ['hey@there.com'], api_key: webhook.token }
      expect(response.status).to eq 200
      json = JSON.parse response.body
      expect(json['added_emails']).to eq ['hey@there.com']
      expect(json['removed_emails']).to eq [existing_email]
    end

    it 'missing permission' do
      webhook = Webhook.create(
        group_id: group.id,
        author_id: group.admins.first.id,
        name: 'group admin bot',
        permissions: []
      )
      post :create, params: { emails: ['hey@there.com'], api_key: webhook.token }
      expect(response.status).to eq 403
    end
  end
end
