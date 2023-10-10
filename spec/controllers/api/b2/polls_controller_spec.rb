require 'rails_helper'

describe API::B2::PollsController do
  let(:group) { create :group }
  let(:bad_group) { create :group }
  let(:bot) { create :user, bot: true}
  let(:admin) { group.admins.first }
  let(:member) { create :user }

  describe 'create' do
    before do
      group.add_member! member
      group.add_admin! bot
    end

    it 'happy case no notifications' do
      post :create, params: {
        group_id: group.id,
        title: 'test',
        poll_type: 'proposal',
        closing_at: 3.days.from_now.iso8601,
        options: ['agree', 'disagree'],
        api_key: bot.api_key,
      }
      expect(response.status).to eq 200
      json = JSON.parse response.body
      poll = json['polls'][0]
      expect(poll['id']).to be_present
      expect(poll['group_id']).to eq group.id
      expect(poll['title']).to eq 'test'
      expect(Poll.find(poll['id']).voters).to_not include(bot)
      expect(Poll.find(poll['id']).voters).to include(admin, member)
    end

    # todo test invalid group id

    it 'happy case notify email' do
      post :create, params: {
        group_id: group.id,
        title: 'test',
        poll_type: 'proposal',
        closing_at: 3.days.from_now.iso8601,
        options: ['agree', 'disagree'],
        recipient_emails: ['test@example.com'],
        api_key: bot.api_key,
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
      post :create, params: {
        group_id: group.id,
        title: 'test',
        poll_type: 'proposal',
        closing_at: 3.days.from_now.iso8601,
        options: ['agree', 'disagree'],
        recipient_user_ids: [member.id],
        api_key: bot.api_key,
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
      post :create, params: {
        group_id: group.id,
        title: 'test',
        poll_type: 'proposal',
        closing_at: 3.days.from_now.iso8601,
        options: ['agree', 'disagree'],
        recipient_audience: 'group',
        api_key: bot.api_key,
      }

      expect(response.status).to eq 200
      json = JSON.parse response.body
      poll = json['polls'][0]
      expect(poll['id']).to be_present
      expect(poll['group_id']).to eq group.id
      expect(poll['title']).to eq 'test'
      expect(Poll.find(poll['id']).voters.count).to eq group.members.humans.count
    end

    it 'missing group id' do
      post :create, params: { title: 'test', api_key: bot.api_key }
      expect(response.status).to eq 422
    end

    it 'incorrect group id' do
      post :create, params: {
        group_id: bad_group.id,
        title: 'test',
        poll_type: 'proposal',
        closing_at: 3.days.from_now.iso8601,
        options: ['agree', 'disagree'],
        recipient_audience: 'group',
        api_key: bot.api_key,
      }
      
      expect(response.status).to eq 403
    end

    it 'incorrect key' do
      post :create, params: {
        group_id: group.id,
        title: 'test',
        poll_type: 'proposal',
        closing_at: 3.days.from_now.iso8601,
        options: ['agree', 'disagree'],
        recipient_audience: 'group',
        api_key: '1234',
      }
      expect(response.status).to eq 403
    end

    it 'missing key' do
      post :create, params: {
        group_id: group.id,
        title: 'test',
        poll_type: 'proposal',
        closing_at: 3.days.from_now.iso8601,
        options: ['agree', 'disagree'],
        recipient_audience: 'group'
      }
      expect(response.status).to eq 403
    end

    it 'blank key' do
      post :create, params: {
        group_id: group.id,
        title: 'test',
        poll_type: 'proposal',
        closing_at: 3.days.from_now.iso8601,
        options: ['agree', 'disagree'],
        recipient_audience: 'group',
        api_key: '',
      }
      expect(response.status).to eq 403
    end
  end
end
