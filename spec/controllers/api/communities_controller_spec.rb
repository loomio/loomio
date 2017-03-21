require 'rails_helper'

describe API::CommunitiesController do
  let(:admin) { create :user }
  let!(:poll) { create :poll, author: admin }
  let(:new_community_params) {{
    community_type: :facebook,
    poll_ids: poll.id,
    custom_fields: {facebook_group_id: "123"}
  }}

  describe 'create' do
    it 'creates a new community' do
      sign_in admin

      expect { post :create, community: new_community_params }.to change { poll.communities.count }.by(1)
      expect(response.status).to eq 200

      community = Communities::Base.last
      expect(community.community_type).to eq new_community_params[:community_type].to_s
      expect(community.custom_fields[:facebook_group_id]).to eq new_community_params[:custom_fields]['facebook_group_id']
      expect(community.polls).to include poll
    end
  end
end
