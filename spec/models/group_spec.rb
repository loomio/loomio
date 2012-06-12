require 'spec_helper'

describe Group do
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
    it "defaults to viewable by everyone" do
      @group.viewable_by.should == :everyone
    end
    it "defaults to members invitable by members" do
      @group.members_invitable_by.should == :members
    end
    it "has a full_name" do
      @group.full_name.should == @group.name
    end
  end

  describe "beta_features" do
    context "group.beta_features = true" do
      before do
        @group = Group.make!
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
          @subgroup = Group.make!(:parent => @group)
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
          @group = Group.make!
          @group.beta_features = false
          @group.save
          @subgroup = Group.make!(:parent => @group)
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
      @group = Group.make!
      @subgroup = Group.make!(:parent => @group)
    end
    it "can access it's parent" do
      @subgroup.parent.should == @group
    end
    it "can access it's children" do
      10.times {Group.make!(:parent => @group)}
      @group.subgroups.count.should eq(11)
    end
    it "limits group inheritance to 1 level" do
      invalid = Group.make(:parent => @subgroup)
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
      @group = Group.make!(viewable_by: "members")
      @user = User.make!
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
    it "can be administered by admin of parent" do
      @subgroup = Group.make(:parent => @group)
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

  context "checking requested users" do
    it "should return true if user has requested access to group" do
      group = Group.make!
      user = User.make!
      user2 = User.make!
      group.add_request!(user)
      group.add_request!(user2)
      group.requested_users_include?(user).should be_true
      group.requested_users_include?(user2).should be_true
    end
  end
end
