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

    it 'creates a new gift subscription for even experiences' do
      group.experiences['bx_choose_plan'] = false
      GroupService.create(group: group, actor: user)
      subscription = group.reload.subscription
      expect(subscription.kind.to_sym).to eq :gift
    end

    it 'creates no subscription for odd experiences' do
      group.experiences['bx_choose_plan'] = true
      GroupService.create(group: group, actor: user)
      expect(group.reload.subscription).to be nil
    end

    it 'does not send excessive emails' do
      expect { GroupService.create(group: group, actor: user) }.to_not change { ActionMailer::Base.deliveries.count }
    end
  end

  describe 'archive!' do
    it 'cancels the subscription' do
      group.add_admin! user
      instance = OpenStruct.new
      allow(SubscriptionService).to receive(:new).and_return(instance)
      expect(instance).to receive :end_subscription!
      GroupService.archive(group: group, actor: user)
    end
  end
end
