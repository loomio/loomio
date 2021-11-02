require 'rails_helper'

describe API::B1::PollsController do
  let(:group) { create :group }
  let(:bad_group) { create :group }
  let(:admin) { group.admins.first }
  let(:member) { create :user }

  describe 'create' do
    before do
      group.add_member! member
    end
    it 'happy case no notifications' do
      webhook = Webhook.create(
        group_id: group.id,
        author_id: group.admins.first.id,
        name: 'group admin bot',
        permissions: ['create_poll']
      )
      post :create, params: {
        title: 'test',
        poll_type: 'proposal',
        closing_at: 3.days.from_now.iso8601,
        options: ['agree', 'disagree'],
        api_key: webhook.token,

      }
      expect(response.status).to eq 200
      json = JSON.parse response.body
      poll = json['polls'][0]
      expect(poll['id']).to be_present
      expect(poll['group_id']).to eq group.id
      expect(poll['title']).to eq 'test'
    end

    it 'happy case notify email' do
      webhook = Webhook.create(
        group_id: group.id,
        author_id: group.admins.first.id,
        name: 'group admin bot',
        permissions: ['create_poll']
      )
      post :create, params: {
        title: 'test',
        poll_type: 'proposal',
        closing_at: 3.days.from_now.iso8601,
        options: ['agree', 'disagree'],
        recipient_emails: ['test@example.com'],
        api_key: webhook.token,

      }
      expect(response.status).to eq 200
      json = JSON.parse response.body
      poll = json['polls'][0]
      expect(poll['id']).to be_present
      expect(poll['group_id']).to eq group.id
      expect(poll['title']).to eq 'test'
      expect(Poll.find(poll['id']).voters.where(email: 'test@example.com').count).to eq 1
    end

    it 'happy case notify user_id' do
      webhook = Webhook.create(
        group_id: group.id,
        author_id: group.admins.first.id,
        name: 'group admin bot',
        permissions: ['create_poll']
      )
      post :create, params: {
        title: 'test',
        poll_type: 'proposal',
        closing_at: 3.days.from_now.iso8601,
        options: ['agree', 'disagree'],
        recipient_user_ids: [member.id],
        api_key: webhook.token,

      }
      expect(response.status).to eq 200
      json = JSON.parse response.body
      poll = json['polls'][0]
      expect(poll['id']).to be_present
      expect(poll['group_id']).to eq group.id
      expect(poll['title']).to eq 'test'
      expect(Poll.find(poll['id']).voters.where(id: member.id).count).to eq 1
    end

    it 'happy case notify group' do
      webhook = Webhook.create(
        group_id: group.id,
        author_id: group.admins.first.id,
        name: 'group admin bot',
        permissions: ['create_poll']
      )
      post :create, params: {
        title: 'test',
        poll_type: 'proposal',
        closing_at: 3.days.from_now.iso8601,
        options: ['agree', 'disagree'],
        recipient_audience: 'group',
        api_key: webhook.token,

      }
      expect(response.status).to eq 200
      json = JSON.parse response.body
      poll = json['polls'][0]
      expect(poll['id']).to be_present
      expect(poll['group_id']).to eq group.id
      expect(poll['title']).to eq 'test'
      expect(Poll.find(poll['id']).voters.count).to eq (group.members.count + 1)
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
