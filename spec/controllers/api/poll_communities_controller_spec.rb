require 'rails_helper'

describe API::PollCommunitiesController do
  let(:poll) { create :poll, author: user }
  let(:community) { create :facebook_community }
  let(:user) { create :user }

  describe 'destroy' do
    before { poll.communities << community }

    it 'removes a community from a particular poll' do
      sign_in user
      expect { delete :destroy, community_id: community.id, poll_id: poll.id }.to change { poll.communities.count }.by(-1)
      expect(response.status).to eq 200
    end

    it 'does not destroy a community' do
      sign_in user
      expect { delete :destroy, community_id: community.id, poll_id: poll.id }.to_not change { Communities::Base.count }
      expect(response.status).to eq 200
    end

    it 'returns unauthorized if no poll is given' do
      delete :destroy, community_id: community.id
      expect(response.status).to eq 403
    end

    it 'does not allow unauthorized users to destroy poll communities' do
      expect { delete :destroy, community_id: community.id, poll_id: poll.id }.to_not change { poll.communities.count }
      expect(response.status).to eq 403
    end
  end
end
