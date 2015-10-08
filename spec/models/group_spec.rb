require 'rails_helper'

describe Group do
  let(:motion) { create(:motion, discussion: discussion) }
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:discussion) { create :discussion }

  context "group creator" do
    it "stores the admin as a creator" do
      expect(group.creator).to eq group.admins.first
    end

    it "delegates language to the group creator" do
      @user = create :user, selected_locale: :fr
      group = create :group, creator: @user
      expect(group.locale).to eq group.creator.locale
    end
  end

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

  context "children counting" do

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

      it "updates correctly after its discussion is archived" do
        expect {
          @discussion.archive!
        }.to change { @group.reload.motions_count }.by(-1)
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

      it "updates correctly after archiving a discussion" do
        @group.discussions.create(attributes_for(:discussion).merge({ author: @user }))
        expect(@group.reload.discussions_count).to eq 1
        expect {
          @group.discussions.first.archive!
        }.to change { @group.reload.discussions_count }.by(-1)
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

  describe "#voting_motions" do
    it "returns motions that belong to the group and are open" do
      @group = motion.group
      @group.voting_motions.should include(motion)
    end

    it "should not return motions that belong to the group but are closed" do
      @group = motion.group
      MotionService.close(motion)
      @group.voting_motions.should_not include(motion)
    end
  end

  describe "#closed_motions" do
    it "returns motions that belong to the group and are open" do
      MotionService.close(motion)
      @group = motion.group
      @group.closed_motions.should include(motion)
    end

    it "should not return motions that belong to the group but are closed'" do
      @group = motion.group
      @group.closed_motions.should_not include(motion)
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
    end

    it "can add a member" do
      @group.add_member!(@user)
      @group.users.should include(@user)
    end
  end

  describe "visible_to" do
    let(:group) { build(:group) }
    subject { group.visible_to }

    before do
      group.is_visible_to_public = false
      group.is_visible_to_parent_members = false
    end

    context "is visible_to_public = true" do
      before { group.is_visible_to_public = true }
      it {should == "public"}
    end

    context "is_visible_to_parent_members = true" do
      before { group.is_visible_to_parent_members = true }
      it {should == "parent_members"}
    end

    context "is_visible_to_public, is_visible_to_parent_members both false" do
      it {should == "members"}
    end
  end

  describe "visible_to=" do
    context "public" do
      before { group.visible_to = 'public' }

      it "sets is_visible_to_public = true" do
        group.is_visible_to_public.should be true
        group.is_visible_to_parent_members.should be false
      end
    end

    context "parent_members" do
      before { group.visible_to = 'parent_members' }
      it "sets is_visible_to_parent_members = true" do
        group.is_visible_to_public.should be false
        group.is_visible_to_parent_members.should be true
      end
    end

    context "members" do
      before { group.visible_to = 'members' }
      it "sets is_visible_to_parent_members and public = false" do
        group.is_visible_to_public.should be false
        group.is_visible_to_parent_members.should be false
      end
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

    context "both are true" do
      it "raises error about it"
      # dont merge before there is a spec here
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

  describe "#has_manual_subscription?" do
    let(:group) { create(:group, payment_plan: 'manual_subscription') }

    it "returns true if group is marked as a manual subscription" do
      group.should have_manual_subscription
    end
    it "returns false if group is not marked as a manual subscription" do
      group.update_attribute(:payment_plan, 'subscription')
      group.should_not have_manual_subscription
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
        group.memberships.all?{|m| m.archived_at.should be_present}
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

  describe 'engagement-scopes' do
    describe 'more_than_n_members' do
      let(:group_with_no_members) { FactoryGirl.create :group }
      let(:group_with_1_member) { FactoryGirl.create :group }
      let(:group_with_2_members) { FactoryGirl.create :group }
      before do
        group_with_no_members.memberships.delete_all
        raise "group with 1 memeber is wrong" unless group_with_1_member.members.size == 1

        group_with_2_members.add_member! FactoryGirl.create(:user)
        raise "group with 2 members is wrong" unless group_with_2_members.members.size == 2
      end

      subject { Group.more_than_n_members(1) }

      it {should include(group_with_2_members) }
      it {should_not include(group_with_1_member, group_with_no_members)}
    end

    describe 'no_active_discussions_since' do
      let(:group_with_no_discussions) { FactoryGirl.create :group, name: 'no discussions' }
      let(:group_with_discussion_1_day_ago) { FactoryGirl.create :group, name: 'discussion 1 day ago' }
      let(:group_with_discussion_3_days_ago) { FactoryGirl.create :group, name: 'discussion 3 days ago' }

      before do
        unless group_with_no_discussions.discussions.size == 0
          raise 'group should not have discussions'
        end

        Timecop.freeze(1.day.ago) do
          group_with_discussion_1_day_ago
          create :discussion, group: group_with_discussion_1_day_ago
        end

        Timecop.freeze(3.days.ago) do
          group_with_discussion_3_days_ago
          create :discussion, group: group_with_discussion_3_days_ago
        end
      end

      subject { Group.no_active_discussions_since(2.days.ago) }

      it {should include(group_with_no_discussions, group_with_discussion_3_days_ago) }
      it {should_not include(group_with_discussion_1_day_ago) }
    end

    describe 'older_than' do
      let(:old_group) { FactoryGirl.create(:group, name: 'old') }
      let(:new_group) { FactoryGirl.create(:group, name: 'new') }
      before do
        Timecop.freeze(1.month.ago) do
          old_group
        end
        Timecop.freeze(1.day.ago) do
          new_group
        end
      end

      subject { Group.created_earlier_than(2.days.ago) }

      it {should include old_group }
      it {should_not include new_group }
    end
  end
end
