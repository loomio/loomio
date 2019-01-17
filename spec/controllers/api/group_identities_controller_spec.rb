require 'rails_helper'

describe API::GroupIdentitiesController do
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:identity) { create :slack_identity, user: user }
  let(:group) { create :formal_group }
  let(:group_identity) { create :group_identity, identity: identity, group: group }
  let(:webhook_identity) { create :microsoft_identity, user: user }
  let(:group_identity_params) {{
    group_id: group.id,
    identity_type: :slack,
    custom_fields: { slack_channel_id: '123', slack_channel_name: 'General' }
  }}
  let(:webhook_group_identity_params) {{
    group_id: group.id,
    identity_type: :microsoft,
    webhook_url: 'https://outlook.office.com/webhook',
    custom_fields: { event_kinds: ['poll_created'] }
  }}

  before { group.add_admin! user }

  describe 'create' do
    before { sign_in user }

    it 'creates a new group identity' do
      identity
      expect { post :create, params: { group_identity: group_identity_params } }.to change { GroupIdentity.count }.by(1)
      expect(response.status).to eq 200
      gi = GroupIdentity.last
      expect(gi.group).to eq group
      expect(gi.identity).to eq identity
      expect(gi.identity.user).to eq user
      expect(gi.identity.identity_type).to eq 'slack'
    end

    it 'updates the group identity if it exists' do
      group_identity
      expect { post :create, params: { group_identity: group_identity_params } }.to_not change { Identities::Base.count }
      expect(GroupIdentity.last.identity).to eq identity
    end

    it 'does not allow unauthorized users to create group identities' do
      group.memberships.find_by(user: user).update(admin: false)
      expect { post :create, params: { group_identity: group_identity_params } }.to_not change { GroupIdentity.count }
      expect(response.status).to eq 403
    end

    it 'handles creating two separate webhooks' do
      webhook_identity
      expect { post :create, params: { group_identity: webhook_group_identity_params } }.to change { Identities::Base.count }
      gi = GroupIdentity.last
      expect(gi.identity).to_not eq webhook_identity
      expect(gi.identity.access_token).to eq webhook_group_identity_params[:webhook_url]
      expect(gi.identity.event_kinds).to include 'poll_created'
      expect(gi.identity.event_kinds).to_not include 'poll_closing_soon'
    end
  end

  describe 'destroy' do
    before { group_identity }

    it 'destroys an existing group identity' do
      sign_in user
      expect { delete :destroy, params: { id: group_identity.id } }.to change  { GroupIdentity.count }.by(-1)
      expect(response.status).to eq 200
    end

    it 'allows other admins to destroy group identities' do
      sign_in another_user
      group.add_admin! another_user
      expect { delete :destroy, params: { id: group_identity.id } }.to change  { GroupIdentity.count }.by(-1)
      expect(response.status).to eq 200
    end

    it 'does not allow unauthorized users to destroy identities' do
      sign_in another_user
      expect { delete :destroy, params: { id: group_identity.id } }.to_not change { GroupIdentity.count }
      expect(response.status).to eq 403
    end
  end
end
