require 'rails_helper'

describe 'GroupService' do
  let(:user) { create(:user) }
  let(:group) { build(:group) }
  let(:parent) { create(:group, default_group_cover: create(:default_group_cover))}
  let(:subgroup) { build(:group, parent: parent) }

  describe 'create' do
    it 'assigns a default group cover' do
      default = create(:default_group_cover)
      GroupService.create(group: group, actor: user)
      expect(default.cover_photo.url).to match group.reload.cover_photo.url
    end

    it 'does not assign a default group cover if the group is a subgroup' do
      parent.add_admin! user
      GroupService.create(group: subgroup, actor: user)
      expect(subgroup.reload.default_group_cover).to be_blank
      expect(subgroup.reload.cover_photo.url).to eq parent.reload.cover_photo.url
    end

    it 'does not assign a default group cover if none have been defined' do
      GroupService.create(group: group, actor: user)
      expect(group.reload.cover_photo).to be_blank
    end

    it 'creates a new trial subscription' do
      GroupService.create(group: group, actor: user)
      subscription = group.reload.subscription
      expect(subscription.kind.to_sym).to eq :trial
      expect(subscription.expires_at.to_date).to eq 30.days.from_now.to_date
    end
  end
end
