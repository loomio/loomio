require 'rails_helper'
describe API::MembershipRequestsController do

  let(:user) { create :user }
  let(:group) { create :group, members_can_add_members: true }
  let(:other_group) { create :group }
  let(:pending_membership_request) { create :membership_request, group: group }
  let(:other_pending_membership_request) { create :membership_request, group: other_group }
  let(:approved_membership_request) { create :membership_request, group: group }

  before do
    group.add_member! user
    pending_membership_request
    approved_membership_request.approve!(user)
    sign_in user
  end

  describe 'pending' do
    context 'permitted' do
      it 'returns users filtered by group' do
        get :pending, params: { group_id: group.id }
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[membership_requests])
        expect(json['membership_requests'].first['id']).to eq pending_membership_request.id
      end
    end

    context 'not permitted' do
      it 'returns AccessDenied' do
        group.update_attribute(:members_can_add_members, false)
        get :pending, params: { group_id: group.id }
        expect(JSON.parse(response.body)['exception']).to include 'CanCan::AccessDenied'
        expect(response.status).to eq 403
      end
    end
  end

  describe 'previous' do
    context 'permitted' do
      it 'returns users filtered by group' do
        get :previous, params: { group_id: group.id }
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[membership_requests])
        expect(json['membership_requests'].first['id']).to eq approved_membership_request.id
      end
    end

    context 'not permitted' do
      it 'returns AccessDenied' do
        group.update_attribute(:members_can_add_members, false)
        get :previous, params: { group_id: group.id }
        expect(JSON.parse(response.body)['exception']).to include 'CanCan::AccessDenied'
        expect(response.status).to eq 403
      end
    end
  end

  describe 'approve' do
    context 'permitted' do
      it 'approves membership request' do
        post :approve, params: { id: pending_membership_request.id }
        record = JSON.parse(response.body)['membership_requests'].first
        expect(record['responder_id']).to eq user.id
        expect(record['response']).to eq 'approved'
      end
    end

    context 'not permitted' do
      it 'raises AccessDenied exception' do
        post :approve, params: { id: other_pending_membership_request.id }
        expect(JSON.parse(response.body)['exception']).to include 'CanCan::AccessDenied'
        expect(response.status).to eq 403
      end
    end
  end

  describe 'ignore' do
    context 'permitted' do
      it 'ignores membership request' do
        post :ignore, params: { id: pending_membership_request.id }
        record = JSON.parse(response.body)['membership_requests'].first
        expect(record['responder_id']).to eq user.id
        expect(record['response']).to eq 'ignored'
      end
    end

    context 'not permitted' do
      it 'raises AccessDenied exception' do
        post :ignore, params: { id: other_pending_membership_request.id }
        expect(JSON.parse(response.body)['exception']).to include 'CanCan::AccessDenied'
        expect(response.status).to eq 403
      end
    end
  end
end
