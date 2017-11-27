require 'rails_helper'

describe 'GroupService' do
  let(:user) { create(:user) }
  let(:group) { build(:formal_group) }
  let(:guest_group) { build(:guest_group) }
  let(:parent) { create(:formal_group, default_group_cover: create(:default_group_cover))}
  let(:subgroup) { build(:formal_group, parent: parent) }

  describe 'create' do
    it 'creates a new group' do
      expect { GroupService.create(group: group, actor: user) }.to change { FormalGroup.count }.by(1)
      expect(group.reload.creator).to eq user
    end

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

    it 'does not send excessive emails' do
      expect { GroupService.create(group: group, actor: user) }.to_not change { ActionMailer::Base.deliveries.count }
    end


    context "is_referral" do
      it "is false for first group" do
        GroupService.create(group: group, actor: user)
        expect(group.is_referral).to be false
      end

      it "is true for second group" do
        create(:formal_group).add_admin! user
        GroupService.create(group: group, actor: user)
        expect(group.is_referral).to be true
      end
    end
  end
end
