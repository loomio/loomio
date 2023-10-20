require 'rails_helper'

describe API::B2::MembershipsController do
  let(:group) { create :group }
  let(:bad_group) { create :group }
  let(:admin) { group.admins.first }

  describe 'create' do
    it 'adds members to group' do
      post :create, params: {
        group_id: group.id,
        emails: ['hey@there.com'],
        api_key: admin.api_key 
      }
      expect(response.status).to eq 200
      json = JSON.parse response.body
      expect(json['added_emails']).to eq ['hey@there.com']
      expect(json['removed_emails']).to eq []
    end

    it 'removes members from group' do
      existing_email = group.admins.first.email
      post :create, params: {
        group_id: group.id,
        remove_absent: 1,
        emails: ['hey@there.com'],
        api_key: admin.api_key
      }
      expect(response.status).to eq 200
      json = JSON.parse response.body
      expect(json['added_emails']).to eq ['hey@there.com']
      expect(json['removed_emails']).to eq [existing_email]
    end

    it 'user is not admin' do
      member = create(:user)
      group.add_member! member
      post :create, params: {
        group_id: group.id,
        emails: ['hey@there.com'],
        api_key: member.api_key 
      }
      expect(response.status).to eq 403
    end

    it 'bad group id' do
      post :create, params: {
        group_id: bad_group.id,
        emails: ['hey@there.com'],
        api_key: admin.api_key 
      }
      expect(response.status).to eq 403
    end

    it 'missing group id' do
      post :create, params: {
        emails: ['hey@there.com'],
        api_key: admin.api_key 
      }
      expect(response.status).to eq 403
    end

    it 'missing api_key' do
      post :create, params: {
        group_id: group.id,
        emails: ['hey@there.com'],
      }
      expect(response.status).to eq 403
    end

    it 'bad api_key' do
      post :create, params: {
        group_id: group.id,
        emails: ['hey@there.com'],
        api_key: 123,
      }
      expect(response.status).to eq 403
    end
  end
end
