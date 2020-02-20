require 'rails_helper'

describe GroupIdentityService do
  let(:group) { create :group }
  let(:group_identity) { build :group_identity, group: group, identity: identity, slack_channel_name: "channel", slack_channel_id: "123" }
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:identity) { create :slack_identity, user: user }
  before { group.add_admin! user }

  describe 'create' do
    it 'creates a new group identity' do
      expect { GroupIdentityService.create(group_identity: group_identity, actor: user) }.to change { group.identities.count }.by(1)
      expect(group.reload.group_identities).to include group_identity
    end

    it 'uses an existing identity if it exists' do
      group_identity.slack_channel_name = "new_channel"
      group.group_identities << group_identity
      expect { GroupIdentityService.create(group_identity: group_identity, actor: user) }.to_not change { group.identities.count }
      expect(group.reload.group_identities.first.slack_channel_name).to eq "new_channel"
    end

    it 'does not allow unauthorized users to create a group identity' do
      expect { GroupIdentityService.create(group_identity: group_identity, actor: another_user) }.to raise_error { CanCan::AccessDenied }
    end

    it 'does not let a user add another users identity' do
      identity.update(user: another_user)
      expect { GroupIdentityService.create(group_identity: group_identity, actor: another_user) }.to raise_error { CanCan::AccessDenied }
    end
  end
end
