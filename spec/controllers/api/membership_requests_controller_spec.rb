require 'rails_helper'
describe API::MembershipRequestsController do

  let(:user) { create :user }
  let(:group) { create :group }
  let(:pending_membership_request) { create :membership_request, group: group }
  let(:approved_membership_request) { create :membership_request, group: group }

  before do
    stub_request(:post, "http://localhost:9292/faye").to_return(status: 200)
    group.admins << user
    pending_membership_request
    approved_membership_request.approve!(user)
    sign_in user
  end

  describe 'pending' do
    context 'success' do
      it 'returns users filtered by group' do
        get :pending, group_id: group.id
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[membership_requests])
        expect(json['membership_requests'].first['id']).to eq pending_membership_request.id
      end
    end
  end

  describe 'responded_to' do
    context 'success' do
      it 'returns users filtered by group' do
        get :responded_to, group_id: group.id
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[membership_requests])
        expect(json['membership_requests'].first['id']).to eq approved_membership_request.id
      end
    end
  end
end
