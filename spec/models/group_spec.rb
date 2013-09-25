require 'spec_helper'

describe Group do
  let(:motion) { create(:motion) }
  let(:user) { create(:user) }
  let(:group) { create(:group) }

  it { should have_many :discussions }

  context "a new group" do
    before :each do
      @group = Group.new
      @group.valid?
      @group
    end

    it "must have a name" do
      @group.should have(1).errors_on(:name)
    end
    it "must have a max_size if it is a parent" do
      group = create(:group)
      group.max_size = nil
      group.valid?
      group.should have(1).errors_on(:max_size)
    end
    it "has memberships" do
      @group.respond_to?(:memberships)
    end
    it "defaults to viewable by members" do
      @group.viewable_by.should == 'members'
    end
    it "defaults to members invitable by members" do
      @group.members_invitable_by.should == 'members'
    end
    it "has a full_name" do
      @group.full_name.should == @group.name
    end
  end

  describe 'invitations_remaining' do
    before do
      @group = Group.new
    end

    it 'is max_size minus members.count' do
      @group.max_size = 10
      @group.should_receive(:memberships_count).and_return 5
      @group.invitations_remaining.should == 5
    end
  end

  describe "#voting_motions" do
    it "returns motions that belong to the group and are open" do
      @group = motion.group
      @group.voting_motions.should include(motion)
    end

    it "should not return motions that belong to the group but are closed" do
      @group = motion.group
      motion.close!
      @group.voting_motions.should_not include(motion)
    end
  end

  describe "#closed_motions" do
    it "returns motions that belong to the group and are open" do
      motion.close!
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

    it "cannot have a max_size" do
      @subgroup.max_size = 5
      @subgroup.save
      @subgroup.should have(1).errors_on(:max_size)
    end

    it "can access it's parent" do
      @subgroup.parent.should == @group
    end

    it "can access it's children" do
      @group.subgroups.count.should eq(1)
    end

    it "limits group inheritance to 1 level" do
      invalid = build(:group, :parent => @subgroup)
      invalid.should_not be_valid
    end

    it "defaults to viewable by parent group members" do
      Group.new(:parent => @group).viewable_by.should == 'parent_group_members'
    end

    context "subgroup.full_name" do
      it "contains parent name" do
        @subgroup.full_name.should == "#{@group.name} - #{@subgroup.name}"
      end
      it "updates if parent_name changes" do
        @group.name = "bluebird"
        @group.save!
        @subgroup.reload
        @subgroup.full_name.should == "#{@group.name} - #{@subgroup.name}"
      end
    end
  end

  context "an existing group viewiable by members" do
    before :each do
      @group = create(:group, viewable_by: "members")
      @user = create(:user)
    end

    it "can add an admin" do
      @group.add_admin!(@user)
      @group.users.should include(@user)
      @group.admins.should include(@user)
    end
    it "can promote existing member to admin" do
      @group.add_member!(@user)
      @group.add_admin!(@user)
    end
    it "can be administered by admin of parent" do
      @subgroup = build(:group, :parent => @group)
      @subgroup.has_admin_user?(@user)
    end
    it "can add a member" do
      @group.add_member!(@user)
      @group.users.should include(@user)
    end
    it "fails silently when trying to add an already-existing member" do
      @group.add_member!(@user)
      @group.add_member!(@user)
    end
  end

  describe 'archive!' do
    let(:group) {FactoryGirl.create(:group)}
    let(:user) {FactoryGirl.create(:user)}

    before do
      group.add_member!(user)
      group.archive!
    end

    it 'sets archived_at on the group' do
      group.archived_at.should be_present

    end

    it 'archives the memberships of the group' do
      group.memberships.all?{|m| m.archived_at.should be_present}
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
          FactoryGirl.create(:discussion, group: group_with_discussion_1_day_ago)
        end

        Timecop.freeze(3.days.ago) do
          group_with_discussion_3_days_ago
          FactoryGirl.create(:discussion, group: group_with_discussion_3_days_ago)
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
