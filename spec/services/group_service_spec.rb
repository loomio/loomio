require 'rails_helper'

describe 'GroupService' do
  let(:user) { create(:user) }
  let(:group) { build(:group) }
  let(:guest_group) { build(:guest_group) }
  let(:parent) { create(:group, default_group_cover: create(:default_group_cover))}
  let(:subgroup) { build(:group, parent: parent) }

  describe 'create' do
    it 'creates a new group' do
      expect { GroupService.create(group: group, actor: user) }.to change { Group.count }.by(1)
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
        create(:group).add_admin! user
        GroupService.create(group: group, actor: user)
        expect(group.is_referral).to be true
      end
    end
  end

  describe' move' do
    let(:group) { create :group, subscription_id: 100 }
    let(:parent) { create :group }
    let(:admin) { create :user, is_admin: true }
    let(:user) { create :user }

    it 'moves a group to a parent as an admin' do
      GroupService.move(group: group, parent: parent, actor: admin)
      expect(group.reload.parent).to eq parent
      expect(group.subscription_id).to be_nil
      expect(parent.reload.subgroups).to include group
    end

    it 'does not allow nonadmins to move groups' do
      expect { GroupService.move(group: group, parent: parent, actor: user) }.to raise_error { CanCan::AccessDenied }
    end
  end

  describe 'merge' do
    let!(:source) { create :group }
    let!(:target) { create :group }
    let!(:user) { create :user, is_admin: true }
    let!(:shared_user) { create :user }
    let!(:source_user) { create :user }
    let!(:target_user) { create :user }
    let!(:source_subgroup) { create :group, parent: source }
    let!(:source_discussion) { create :discussion, group: source }
    let!(:source_comment) { create :comment, discussion: source_discussion }
    let!(:source_poll) { create :poll, group: source }
    let!(:source_stance) { create :stance, poll: source_poll }
    let!(:source_identity) { create :group_identity, group: source }
    let!(:source_request) { create :membership_request, group: source }

    before do
      source.add_member! source_user
      target.add_member! target_user
      source.add_member! shared_user
      target.add_member! shared_user
    end

    it 'can merge two groups' do
      GroupService.merge(source: source, target: target, actor: user)
      target.reload
      expect(target.subgroups).to           include source_subgroup
      expect(target.members).to             include source_user
      expect(target.members).to             include target_user
      expect(target.members).to             include shared_user
      expect(Membership.where(user: shared_user, group: target).count).to eq 1

      expect(target.discussions).to         include source_discussion
      expect(target.polls).to               include source_poll
      expect(target.group_identities).to    include source_identity
      expect(target.membership_requests).to include source_request

      expect(source_stance.reload.group).to eq target
      expect(source_comment.reload.group).to eq target

      expect { source.reload }.to raise_error { ActiveRecord::RecordNotFound }
    end

    it 'does not allow non-admins to merge' do
      user.update(is_admin: false)
      expect { GroupService.merge(source: source, target: target, actor: user) }.to raise_error { CanCan::AccessDenied }
    end
  end
end
