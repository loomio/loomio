require 'rails_helper'

describe 'GroupService' do
  let(:user) { create(:user) }
  let(:group) { build(:group) }
  let(:parent) { create(:group, default_group_cover: create(:default_group_cover))}
  let(:subgroup) { build(:group, parent: parent) }

  describe 'create' do
    it 'creates a new group' do
      expect { GroupService.create(group: group, actor: user) }.to change { Group.count }.by(1)
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

    it 'sets the actor as group creator if logged in' do
      GroupService.create(group: group, actor: user)
      expect(group.reload.creator).to eq user
    end

    it 'leaves the group creator nil if user does not have account' do
      GroupService.create(group: group, actor: LoggedOutUser.new)
      expect(group.reload.creator).to be_nil
    end

    context "is_referral" do
      it "is false for first group" do
        GroupService.create(group: group, actor: user)
        expect(group.is_referral).to be false
      end

      it "is true for second group" do
        create(:group).add_admin! user
        GroupService.create(group: group, actor: user)
        expect(group.is_referral).to be true
      end
    end
  end
end
