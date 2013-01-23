require 'spec_helper'

describe Group do
  let(:motion) { create(:motion) }

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
    it "has memberships" do
      @group.respond_to?(:memberships)
    end
    it "defaults to viewable by members" do
      @group.viewable_by.should == :members
    end
    it "defaults to members invitable by members" do
      @group.members_invitable_by.should == :members
    end
    it "has a full_name" do
      @group.full_name.should == @group.name
    end
  end

  describe "#create" do
    #context "creates a 'welcome to loomio' discussion and" do
      #before do
        #@group = create :group
        #@discussion = @group.discussions.first
      #end

      #it "sets the title" do
        #@discussion.title.should == "Example Discussion: Welcome and introduction to Loomio!"
      #end

      #it "sets the description" do
        #@discussion.description.should_not be_nil
      #end

      #it "assigns Loomio Helper Bot as the author" do
        #@discussion.author_id.should == User.loomio_helper_bot.id
      #end

      #it "creates an initial comment" do
        #@discussion.comments.count.should == 1
      #end

      #it "creates a new motion" do
        #@discussion.motions.count.should == 1
      #end
    #end

    #it "does not create a 'welcome to loomio' discussion for subgroups" do
      #parent = create :group
      #group = create :group, :parent => parent
      #group.discussions.should be_empty
    #end

    it "adds the creator as an admin" do
      @group = create :group
      @group.admins.should include(@group.creator)
    end
  end

  describe "motions_in_voting_phase" do
    it "returns motions that belong to the group and are in phase 'voting'" do
      @group = motion.group
      @group.motions_in_voting_phase.should include(motion)
    end

    it "should not return motions that belong to the group but are in phase 'closed'" do
      @group = motion.group
      motion.close!
      @group.motions_in_voting_phase.should_not include(motion)
    end
  end

  describe "motions_closed" do
    it "returns motions that belong to the group and are in phase 'voting'" do
      motion.close!
      @group = motion.group
      @group.motions_closed.should include(motion)
    end

    it "should not return motions that belong to the group but are in phase 'closed'" do
      @group = motion.group
      @group.motions_closed.should_not include(motion)
    end
  end

  # NOTE (Jon): these descriptions seem ridiculous,
  # why did i name the tests this way? mehh.....
  describe "beta_features" do
    context "group.beta_features = true" do
      before do
        @group = create(:group)
        @group.beta_features = true
        @group.save
      end
      it "group.beta_features? returns true" do
        @group.beta_features?.should be_true
      end
      it "group.beta_features returns true" do
        @group.beta_features.should be_true
      end
      context "subgroup.beta_features = false" do
        before do
          @subgroup = create(:group, :parent => @group)
          @subgroup.beta_features = false
          @subgroup.save
        end
        it "subgroup.beta_features? returns true" do
          @subgroup.beta_features?.should be_true
        end
        it "subgroup.beta_features returns true" do
          @subgroup.beta_features.should be_true
        end
      end
    end
    context "group.beta_features = false" do
      context "subgroup.beta_features = true" do
        before do
          @group = create(:group)
          @group.beta_features = false
          @group.save
          @subgroup = create(:group, :parent => @group)
          @subgroup.beta_features = true
          @subgroup.save
        end
        it "subgroup.beta_features? returns true" do
          @subgroup.beta_features?.should be_true
        end
        it "subgroup.beta_features returns true" do
          @subgroup.beta_features.should be_true
        end
      end
    end
  end

  context "has a parent" do
    before :each do
      @group = create(:group)
      @subgroup = create(:group, :parent => @group)
    end
    it "can access it's parent" do
      @subgroup.parent.should == @group
    end
    it "can access it's children" do
      10.times {create(:group, :parent => @group)}
      @group.subgroups.count.should eq(11)
    end
    it "limits group inheritance to 1 level" do
      invalid = build(:group, :parent => @subgroup)
      invalid.should_not be_valid
    end
    it "defaults to viewable by parent group members" do
      Group.new(:parent => @group).viewable_by.should == :parent_group_members
    end
    context "subgroup.full_name" do
      it "contains parent name" do
        @subgroup.full_name.should == "#{@subgroup.parent_name} - #{@subgroup.name}"
        @subgroup.full_name(": ").should ==
          "#{@subgroup.parent_name}: #{@subgroup.name}"
      end
      it "can have an optionally defined separator between names" do
        @subgroup.full_name(": ").should ==
          "#{@subgroup.parent_name}: #{@subgroup.name}"
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
    it "can promote requested member to admin" do
      @group.add_request!(@user)
      @group.add_admin!(@user)
    end
    it "has an admin email" do
      @group.admin_email.should == @group.creator_email
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
    it "fails silently when trying to request an already-requested member" do
      @group.add_request!(@user)
      @group.add_request!(@user)
    end
    it "fails silently when trying to request an already-existing member" do
      @group.add_member!(@user)
      @group.add_request!(@user)
      @group.users.should include(@user)
    end
    it "can add a member if a request has already been created" do
      @group.add_request!(@user)
      @group.add_member!(@user)
      @group.users.should include(@user)
    end

    context "receiving a member request" do
      it "should not add user to group" do
        @group.add_request!(@user)
        @group.users.should_not include(@user)
      end
      it "should add user to member requests" do
        @group.add_request!(@user)
        @group.membership_requests.find_by_user_id(@user).should \
          == @user.membership_requests.find_by_group_id(@group)
      end
      it "should send group admins a notification email" do
        GroupMailer.should_receive(:new_membership_request).with(kind_of(Membership))
          .and_return(stub(deliver: true))
        @group.add_request!(@user)
      end
    end
  end

  describe "activity_since_last_viewed?(user)" do
    before do
      @group = create(:group)
      @user = create(:user)
      @membership = create :membership, group: @group, user: @user
    end
    context "where user is a member" do
      before do
        @group.stub(:membership).with(@user).and_return(@membership)
      end
      it "returns false if there is new activity since this group was last viewed but does not have any discussions with unread activity" do
        @group.discussions.stub_chain(:includes, :where, :count).and_return(3)
        @group.discussions.stub_chain(:joins, :where, :count).and_return(0)
        @group.activity_since_last_viewed?(@user).should == false
      end
      it "returns false if there is no new activity since this group was last viewed but does have discussions with unread activity" do
        @group.discussions.stub_chain(:includes, :where, :count).and_return(3)
        @group.discussions.stub_chain(:joins, :where, :count).and_return(0)
        @group.activity_since_last_viewed?(@user).should == false
      end
      it "returns true if there is no new activity since this group was last viewed but does have discussions with unread activity" do
        @group.discussions.stub_chain(:includes, :where, :count).and_return(3)
        @group.discussions.stub_chain(:joins, :where, :count).and_return(2)
        @group.activity_since_last_viewed?(@user).should == true
      end
    end
    it "returns false there is no membership" do
      @group.stub(:membership).with(@user)
      @group.activity_since_last_viewed?(@user).should == false
    end
  end
end
