require 'rails_helper'

describe API::GroupIdentitiesController do
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:identity) { create :slack_identity, user: user }
  let(:group) { create :formal_group }
  let(:group_identity) { create :group_identity, identity: identity, group: group }

  before { group.add_admin! user }

  # TODO :(
  describe 'create' do
    it 'updates the group identity if it exists' do

    end

    it 'uses the actor identity if group does not have one' do

    end

    it 'does not allow unauthorized uses to create group identities' do

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
