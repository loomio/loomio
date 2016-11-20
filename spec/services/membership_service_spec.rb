require 'rails_helper'

describe MembershipService do
  let(:group) { create :group, discussion_privacy_options: :public_only, is_visible_to_public: true, membership_granted_upon: :request }
  let(:user)  { create :user }

  describe 'join_group' do
    it 'adds the user as creator if the group has no creator' do
      MembershipService.join_group(group: group, actor: user)
      expect(group.reload.creator).to eq user
    end

    it 'does not eliminate the former creator' do
      group.update(creator: create(:user))
      MembershipService.join_group(group: group, actor: user)
      expect(group.reload.creator).to_not eq user
    end
  end

end
