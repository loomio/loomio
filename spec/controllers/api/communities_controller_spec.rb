require 'rails_helper'

describe API::CommunitiesController do
  let(:user) { create :user }
  let!(:poll) { create :poll, author: user }
  let(:another_poll) { create :poll }
  let(:community) { create :facebook_community }
  let!(:identity) { create :facebook_identity, user: user }
  let(:existing_community) { create :facebook_community, new_community_params.merge(poll_id: another_poll.id) }
  let(:new_community_params) {{
    community_type: :facebook,
    identity_id: identity.id,
    poll_id: poll.id,
    identifier: "123"
  }}

  describe 'create' do
    it 'creates a new community' do
      sign_in user

      expect { post :create, community: new_community_params }.to change { poll.communities.count }.by(1)
      expect(response.status).to eq 200

      community = Communities::Base.last
      expect(community.community_type).to eq new_community_params[:community_type].to_s
      expect(community.identifier).to eq new_community_params[:identifier]
      expect(community.polls).to include poll
    end

    it 'updates an existing community if it exists' do
      sign_in user
      existing_community

      expect { post :create, community: new_community_params }.to_not change { Communities::Base.count }
      expect(response.status).to eq 200
      expect(existing_community.reload.polls).to include poll
      expect(poll.reload.communities).to include existing_community
    end

    it 'does not allow logged out users to create communities' do
      expect { post :create, community: new_community_params }.to_not change { poll.communities.count }
      expect(response.status).to eq 403
    end

    it 'does not allow a community to be created without a type' do
      sign_in user
      new_community_params[:community_type] = ''

      expect { post :create, community: new_community_params }.to_not change { poll.communities.count }
      expect(response.status).to eq 422
    end
  end

  describe 'index' do
    let!(:slack_community)    { create :slack_community, identity: identity }
    let!(:facebook_community) { create :facebook_community, identity: identity }
    let!(:poll_community)     { create :facebook_community, poll_id: poll.id }
    let!(:identity)           { create :facebook_identity, user: user }
    let(:poll)                { create :poll, author: user }

    it 'can get a list of communities on a poll' do
      sign_in user

      get :index, poll_id: poll.id
      expect(response.status).to eq 200

      json = JSON.parse(response.body)
      community_ids = json['communities'].map { |c| c['id'] }
      expect(community_ids).to include poll_community.id
      expect(community_ids).to_not include slack_community.id

      poll_ids = json['communities'].map { |c| c['poll_id'] }
      expect(poll_ids).to include poll.id
    end

    it 'does not show communities to users who cannot see the poll' do
      get :index, poll_id: poll
      expect(response.status).to eq 403
    end
  end
end
