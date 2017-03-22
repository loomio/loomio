require 'rails_helper'

describe API::CommunitiesController do
  let(:user) { create :user }
  let!(:poll) { create :poll, author: user }
  let(:community) { create :facebook_community }
  let(:new_community_params) {{
    community_type: :facebook,
    poll_id: poll.id,
    custom_fields: {facebook_group_id: "123"}
  }}

  describe 'create' do
    it 'creates a new community' do
      sign_in user

      expect { post :create, community: new_community_params }.to change { poll.communities.count }.by(1)
      expect(response.status).to eq 200

      community = Communities::Base.last
      expect(community.community_type).to eq new_community_params[:community_type].to_s
      expect(community.custom_fields[:facebook_group_id]).to eq new_community_params[:custom_fields]['facebook_group_id']
      expect(community.polls).to include poll
    end

    it 'uses an existing community if one exists' do
      sign_in user
      existing = create :facebook_community, custom_fields: { facebook_group_id: new_community_params[:custom_fields][:facebook_group_id] }

      expect { post :create, community: new_community_params }.to_not change { Communities::Base.count }
      expect(poll.reload.communities).to include existing
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

    it 'can get a list of communities on a user' do
      sign_in user

      get :index
      expect(response.status).to eq 200

      json = JSON.parse(response.body)
      community_ids = json['communities'].map { |c| c['id'] }
      expect(community_ids).to_not include poll_community.id
      expect(community_ids).to include slack_community.id
      expect(community_ids).to include facebook_community.id
    end

    it 'can filter by type' do
      sign_in user

      get :index, types: [:facebook]

      json = JSON.parse(response.body)
      community_ids = json['communities'].map { |c| c['id'] }
      expect(community_ids).to_not include slack_community.id
      expect(community_ids).to include facebook_community.id
    end

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

    it 'does not show communities to logged out users' do
      get :index
      expect(response.status).to eq 200
      json = JSON.parse(response.body)
      expect(json['communities']).to be_empty
    end
  end

  describe 'add' do
    before { community }

    it 'adds a community to a poll' do
      sign_in user
      expect { post :add, id: community.id, poll_id: poll.id }.to change { poll.communities.count }.by(1)
      expect(response.status).to eq 200
    end

    it 'does not create a new community' do
      sign_in user
      expect { post :add, id: community.id, poll_id: poll.id }.to_not change { Communities::Base.count }
    end

    it 'returns unauthorized if no poll is given' do
      post :add, id: community.id
      expect(response.status).to eq 404
    end

    it 'does not allow unauthorized users to add poll communities' do
      expect { post :add, id: community.id, poll_id: poll.id }.to_not change { poll.communities.count }
    end
  end

  describe 'remove' do
    before { poll.communities << community }

    it 'removes a community from a particular poll' do
      sign_in user
      expect { post :remove, id: community.id, poll_id: poll.id }.to change { poll.communities.count }.by(-1)
      expect(response.status).to eq 200
    end

    it 'does not destroy a community' do
      sign_in user
      expect { post :remove, id: community.id, poll_id: poll.id }.to_not change { Communities::Base.count }
      expect(response.status).to eq 200
    end

    it 'returns unauthorized if no poll is given' do
      post :remove, id: community.id
      expect(response.status).to eq 404
    end

    it 'does not allow unauthorized users to destroy poll communities' do
      expect { post :remove, id: community.id, poll_id: poll.id }.to_not change { poll.communities.count }
      expect(response.status).to eq 403
    end
  end
end
