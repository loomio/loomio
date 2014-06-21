require 'spec_helper'

describe Group do
  let(:motion) { create(:motion, discussion: discussion) }
  let(:user) { create(:user) }
  let(:group) { create(:group) }
  let(:discussion) { create_discussion }

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
        group.is_visible_to_public.should be_true
        group.is_visible_to_parent_members.should be_false
      end
    end

    context "parent_members" do
      before { group.visible_to = 'parent_members' }
      it "sets is_visible_to_parent_members = true" do
        group.is_visible_to_public.should be_false
        group.is_visible_to_parent_members.should be_true
      end
    end

    context "members" do
      before { group.visible_to = 'members' }
      it "sets is_visible_to_parent_members and public = false" do
        group.is_visible_to_public.should be_false
        group.is_visible_to_parent_members.should be_false
      end
    end
  end

  describe "parent_members_can_see_discussions_is_valid?" do
    context "parent_members_can_see_discussions = true" do
      it "errors for a parent group" do
        expect { create(:group,
                        parent_members_can_see_discussions: true) }.to raise_error
      end

      it "errors for a hidden_from_everyone subgroup" do
        expect { create(:group,
                        is_visible_to_public: false,
                        is_visible_to_parent_members: false,
                        parent: create(:group),
                        parent_members_can_see_discussions: true) }.to raise_error
      end

      it "errors for a visible_to_public subgroup" do
        expect { create(:group,
                        is_visible_to_public: true,
                        parent: create(:group,
                                       is_visible_to_public: true),
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

  describe 'archive!' do
    before do
      group.add_member!(user)
      @discussion = create_discussion group_id: group.id
      group.archive!
    end

    it 'sets archived_at on the group' do
      group.archived_at.should be_present
    end

    it 'archives the memberships of the group' do
      group.memberships.all?{|m| m.archived_at.should be_present}
    end

    it 'archives the discussions' do
      group.discussions.all?{|d| d.archived_at.should be_present}
    end
  end

  describe 'is_paying?', focus: true do
    subject do
      group.is_paying?
    end

    context 'payment_plan is manual' do
      before do
        group.payment_plan = "manual_subscription"
      end
      it {should be_true}
    end

    context 'payment_plan is pwyc or undetermined' do
      it {should be_false}
    end

    context 'group has online subscription' do
      before do
        group.subscription = Subscription.create(group: group, amount: 0)
      end

      context 'with amount 0' do
        it {should be_false}
      end

      context 'with amount > 0' do
        before do
          group.subscription.amount = 1
        end
        it {should be_true}
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
          create_discussion group: group_with_discussion_1_day_ago
        end

        Timecop.freeze(3.days.ago) do
          group_with_discussion_3_days_ago
          create_discussion group: group_with_discussion_3_days_ago
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
