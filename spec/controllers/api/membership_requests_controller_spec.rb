require 'rails_helper'
describe API::MembershipRequestsController do

  let(:user) { create :user }
  let(:group) { create :group }
  let(:membership_request) { create :membership_request, group: group }

  before do
    stub_request(:post, "http://localhost:9292/faye").to_return(status: 200)
    group.admins << user
    membership_request
    sign_in user
  end

  describe 'pending' do
    context 'success' do
      it 'returns users filtered by group' do
        get :pending, group_id: group.id
        json = JSON.parse(response.body)
        expect(json.keys).to include *(%w[membership_requests])
      end
    end
  end
end
