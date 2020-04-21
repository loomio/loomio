require 'rails_helper'

describe GroupQuery do
  let!(:user) { create :user }
  let!(:group) { create :group, name: 'group', group_privacy: 'secret' }
  let!(:subgroup) { create :group, name: 'subgroup', parent: parent, is_visible_to_parent_members: true, group_privacy: 'secret'}
  let!(:parent) { create :group, name: 'parent', group_privacy: 'secret' }
  let!(:rando) { create :group, group_privacy: 'secret' }
  let!(:public_group) { create :group, group_privacy: 'open' }

  describe 'visible_to' do
    before do
      group.add_member! user
      parent.add_member! user
    end

    it 'finds groups the user can see' do
      results = GroupQuery.visible_to(user: user)
      expect(results).to include group
      expect(results).to include subgroup
      expect(results).to include parent
      expect(results).to_not include rando
    end

    it 'finds groups the user can see and public groups' do
      results = GroupQuery.visible_to(user: user, show_public: true)
      expect(results).to include group
      expect(results).to include subgroup
      expect(results).to include parent
      expect(results).to include public_group
      expect(results).to_not include rando
    end

    it 'finds public groups' do
      results = GroupQuery.visible_to(show_public: true)
      expect(results).to include public_group
      expect(results).to_not include rando
      expect(results).to_not include group
      expect(results).to_not include subgroup
      expect(results).to_not include parent
    end
  end
end
