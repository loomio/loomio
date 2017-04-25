require 'rails_helper'

describe Group do
  let(:motion) { create(:motion, discussion: discussion) }
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:discussion) { create :discussion, group: group }

  context 'default cover photo' do

    it 'returns an uploaded cover url if one exists' do
      cover_photo_stub = OpenStruct.new(url: 'test.jpg')
      group = create :group, default_group_cover: create(:default_group_cover)
      group.stub(:cover_photo).and_return(cover_photo_stub)
      expect(cover_photo_stub.url).to match group.cover_photo.url
    end

    it 'returns the default cover photo for the group if it is a parent group' do
      group = create :group, default_group_cover: create(:default_group_cover)
      expect(group.default_group_cover.cover_photo.url).to match group.cover_photo.url
    end

    it 'returns the parents default cover photo if it is a subgroup' do
      parent = create :group, default_group_cover: create(:default_group_cover)
      group = create :group, parent: parent
      expect(parent.default_group_cover.cover_photo.url).to match group.cover_photo.url
    end
  end

  context "counter caches" do
    describe 'invitations_count' do
      before do
        @group = create(:group, creator: create(:user))
        @user  = create(:user)
      end

      it 'increments when a new invitation is created' do
        InvitationService.invite_to_group(recipient_emails: [@user.email],
                                          group: @group,
                                          inviter: @group.creator)
        expect(@group.invitations_count).to eq 1
      end
    end

    describe "#motions_count" do
      before do
        @group = create(:group)
        @user = create(:user)
        @discussion = create(:discussion, group: @group)
        @motion = create(:motion, discussion: @discussion)
      end

      it "returns a count of motions" do
        expect(@group.reload.motions_count).to eq 1
      end

      it "updates correctly after creating a motion" do
        expect {
          @discussion.motions.create(attributes_for(:motion).merge({ author: @user }))
        }.to change { @group.reload.motions_count }.by(1)
      end

      it "updates correctly after deleting a motion" do
        expect {
          @motion.destroy
        }.to change { @group.reload.motions_count }.by(-1)
      end

      it "updates correctly after its discussion is destroyed" do
        expect {
          @discussion.destroy
        }.to change { @group.reload.motions_count }.by(-1)
      end
    end

    describe "#closed_motions_count" do
      before do
        motion.close!
      end

      it "returns a count of closed motions" do
        expect(group.reload.closed_motions_count).to eq 1
      end

      it "updates correctly after motion is closed" do
        expect {
          discussion.motions.create(attributes_for(:motion).merge({ author: user })).close!
        }.to change { group.reload.closed_motions_count }.by(1)
      end

      it "updates correctly after deleting a motion" do
        expect { motion.destroy }.to change { group.reload.closed_motions_count }.by(-1)
      end

      it "updates correctly after its discussion is destroyed" do
        expect {
          discussion.destroy
        }.to change { group.reload.closed_motions_count }.by(-1)
      end
    end

    describe "#discussions_count" do
      before do
        @group = create(:group)
        @user = create(:user)
      end

      it "returns a count of discussions" do
        expect {
          @group.discussions.create(attributes_for(:discussion).merge({ author: @user }))
        }.to change { @group.reload.discussions_count }.by(1)
      end

      it "updates correctly after deleting a discussion" do
        @group.discussions.create(attributes_for(:discussion).merge({ author: @user }))
        expect(@group.reload.discussions_count).to eq 1
        expect {
          @group.discussions.first.destroy
        }.to change { @group.reload.discussions_count }.by(-1)
      end
    end
  end

  context "subgroup" do
    before :each do
      @group = create(:group)
      @subgroup = create(:group, :parent => @group)
      @group.reload
    end

    context "subgroup.full_name" do
      it "contains parent name" do
        expect(@subgroup.full_name).to eq "#{@group.name} - #{@subgroup.name}"
      end

      it "updates if parent_name changes" do
        @group.name = "bluebird"
        @group.save!
        @subgroup.reload
        expect(@subgroup.full_name).to eq "#{@group.name} - #{@subgroup.name}"
      end
    end
  end

  context "an existing hidden group" do
    before :each do
      @group = create(:group, is_visible_to_public: false)
      @user = create(:user)
    end

    it "can promote existing member to admin" do
      @group.add_member!(@user)
      @group.add_admin!(@user)
      expect(@group.admins).to include @user
    end

    it "can add a member" do
      @group.add_member!(@user)
      expect(@group.users).to include @user
    end

    it 'sets the first admin to be the creator' do
      @group = Group.new(name: "Test group")
      @group.add_admin!(@user)
      expect(@group.creator).to eq @user
    end
  end

  describe "parent_members_can_see_discussions_is_valid?" do
    context "parent_members_can_see_discussions = true" do

      it "errors for a hidden_from_everyone subgroup" do
        expect { create(:group,
                        is_visible_to_public: false,
                        is_visible_to_parent_members: false,
                        parent: create(:group),
                        parent_members_can_see_discussions: true) }.to raise_error
      end

      it "does not error for a visible to parent subgroup" do
        expect { create(:group,
                        is_visible_to_public: false,
                        is_visible_to_parent_members: true,
                        parent: create(:group),
                        parent_members_can_see_discussions: true) }.to_not raise_error
      end
    end
  end

  describe "parent_members_can_see_group_is_valid?" do
    context "parent_members_can_see_group = true" do
      it "for a parent group" do
        expect { create(:group,
                        parent_members_can_see_group: true) }.to raise_error
      end

      it "for a hidden subgroup" do
        expect { create(:group,
                        is_visible_to_public: false,
                        is_visible_to_parent_members: true,
                        parent: create(:group)) }.to_not raise_error
      end

      it "for a visible subgroup" do
        expect { create(:group,
                        is_visible_to_public: true,
                        parent: create(:group,
                                       is_visible_to_public: true),
                        parent_members_can_see_group: true) }.to raise_error
      end
    end
  end

  describe 'archival' do
    before do
      group.add_member!(user)
      group.archive!
    end

    describe '#archive!' do

      it 'sets archived_at on the group' do
        group.archived_at.should be_present
      end

      it 'archives the memberships of the group' do
        group.memberships.reload.all?{|m| m.reload.archived_at.should be_present}
      end
    end

    describe '#unarchive!' do
      before do
        group.unarchive!
      end

      it 'restores archived_at to nil on the group' do
        group.archived_at.should be_nil
      end

      it 'restores the memberships of the group' do
        group.memberships.all?{|m| m.archived_at.should be_nil}
      end
    end
  end

  describe 'id_and_subgroup_ids' do
    let(:group) { create(:group) }
    let(:subgroup) { create(:group, parent: group) }

    it 'returns empty for new group' do
      expect(build(:group).id_and_subgroup_ids).to be_empty
    end

    it 'returns the id for groups with no subgroups' do
      expect(group.id_and_subgroup_ids).to eq [group.id]
    end

    it 'returns the id and subgroup ids for group with subgroups' do
      subgroup; group.reload
      expect(group.id_and_subgroup_ids).to include group.id
      expect(group.id_and_subgroup_ids).to include subgroup.id
    end
  end

  describe 'community' do
    it 'creates a new community if one does not exist' do
      expect(group.community_id).to be_nil
      expect(group.community).to be_a Communities::LoomioGroup
      expect(group.community.group).to eq group
    end
  end

  describe 'uses_polls' do
    it 'defaults to true' do
      expect(Group.new.features['use_polls']).to eq true
    end
  end
end
