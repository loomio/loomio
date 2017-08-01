require 'rails_helper'

describe Group do
  let(:user) { create(:user) }
  let(:group) { create(:formal_group) }
  let(:discussion) { create :discussion, group: group }

  context 'default cover photo' do

    it 'returns an uploaded cover url if one exists' do
      cover_photo_stub = OpenStruct.new(url: 'test.jpg')
      group = create :formal_group, default_group_cover: create(:default_group_cover)
      group.stub(:cover_photo).and_return(cover_photo_stub)
      expect(cover_photo_stub.url).to match group.cover_photo.url
    end

    it 'returns the default cover photo for the group if it is a parent group' do
      group = create :formal_group, default_group_cover: create(:default_group_cover)
      expect(group.default_group_cover.cover_photo.url).to match group.cover_photo.url
    end

    it 'returns the parents default cover photo if it is a subgroup' do
      parent = create :formal_group, default_group_cover: create(:default_group_cover)
      group = create :formal_group, parent: parent
      expect(parent.default_group_cover.cover_photo.url).to match group.cover_photo.url
    end
  end

  context 'logo_or_parent_logo' do
    it 'returns the group logo if it is a parent' do
      group = create :formal_group
      expect(group.logo_or_parent_logo).to eq group.logo
    end

    it 'returns the parents logo if one does not exist' do
      parent = create :formal_group, logo: fixture_for('images', 'strongbad.png')
      group = create :formal_group, parent: parent
      expect(group.logo_or_parent_logo).to eq parent.logo
    end

    it 'returns the group logo if one exists' do
      parent = create :formal_group
      group = create :formal_group, parent: parent, logo: fixture_for('images', 'strongbad.png')
      expect(group.logo_or_parent_logo).to eq group.logo
    end
  end

  context "counter caches" do
    describe 'invitations_count' do
      before do
        @group = create(:formal_group, creator: create(:user))
        @user  = create(:user)
      end

      it 'increments when a new invitation is created' do
        InvitationService.invite_to_group(recipient_emails: [@user.email],
                                          group: @group,
                                          inviter: @group.creator)
        expect(@group.invitations_count).to eq 1
      end
    end

    describe "#discussions_count" do
      before do
        @group = create(:formal_group)
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
      @group = create(:formal_group)
      @subgroup = create(:formal_group, :parent => @group)
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
      @group = create(:formal_group, is_visible_to_public: false)
      @user = create(:user)
    end

    it "can promote existing member to admin" do
      @group.add_member!(@user)
      @group.add_admin!(@user)
      expect(@group.admins).to include @user
    end

    it "can add a member" do
      @group.add_member!(@user)
      expect(@group.members).to include @user
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
        expect { create(:formal_group,
                        is_visible_to_public: false,
                        is_visible_to_parent_members: false,
                        parent: create(:formal_group),
                        parent_members_can_see_discussions: true) }.to raise_error
      end

      it "does not error for a visible to parent subgroup" do
        expect { create(:formal_group,
                        is_visible_to_public: false,
                        is_visible_to_parent_members: true,
                        parent: create(:formal_group),
                        parent_members_can_see_discussions: true) }.to_not raise_error
      end
    end
  end

  describe "parent_members_can_see_group_is_valid?" do
    context "parent_members_can_see_group = true" do
      it "for a parent group" do
        expect { create(:formal_group,
                        parent_members_can_see_group: true) }.to raise_error
      end

      it "for a hidden subgroup" do
        expect { create(:formal_group,
                        is_visible_to_public: false,
                        is_visible_to_parent_members: true,
                        parent: create(:formal_group)) }.to_not raise_error
      end

      it "for a visible subgroup" do
        expect { create(:formal_group,
                        is_visible_to_public: true,
                        parent: create(:formal_group,
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
    let(:group) { create(:formal_group) }
    let(:subgroup) { create(:formal_group, parent: group) }

    it 'returns empty for new group' do
      expect(build(:formal_group).id_and_subgroup_ids).to be_empty
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
end
