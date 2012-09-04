require 'spec_helper'

describe Group do
  let(:motion) { create_motion }

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


  describe "methods for filtering discussions on weather a user has voted: " do
    before do
      @user = User.make!
      @group = Group.make!
      group1 = Group.make!
      @group.add_member!(@user)
      group1.add_member!(@user)
      @discussion1 = create_discussion(group: @group)
      motion1 = create_motion(discussion: @discussion1, author: @user)
      @discussion2 = create_discussion(group: @group)
      motion2 = create_motion(discussion: @discussion2, author: @user)
      @discussion3 = create_discussion(group: group1, author:@user)
      motion3 = create_motion(discussion: @discussion3, author: @user)
      vote = Vote.new(position: "yes")
      vote.motion = motion2
      vote.user = @user
      vote.save
      vote = Vote.new(position: "yes")
      vote.motion = motion3
      vote.user = @user
      vote.save
    end
    describe "discussions_with_current_motion_voted_on(user)" do
      it "should return all discussion in the group with a current motion that a user has voted on" do
        @group.discussions_with_current_motion_voted_on(@user).should include(@discussion2)
        @group.discussions_with_current_motion_voted_on(@user).should_not include(@discussion1)
        @group.discussions_with_current_motion_voted_on(@user).should_not include(@discussion3)
      end
    end
    describe "discussions_with_current_motion_not_voted_on(user)" do
      it "should return all discussion in the group with a current motion that a user has not voted on" do
        @group.discussions_with_current_motion_not_voted_on(@user).should include(@discussion1)
        @group.discussions_with_current_motion_not_voted_on(@user).should_not include(@discussion2)
        @group.discussions_with_current_motion_not_voted_on(@user).should_not include(@discussion3)
      end
    end
  end


  describe "motions_in_voting_phase" do
    it "should return motions that belong to the group and are in phase 'voting'" do
      @group = motion.group
      @group.motions_in_voting_phase.should include(motion)
    end

    it "should not return motions that belong to the group but are in phase 'closed'" do
      @group = motion.group
      motion.close_voting!
      @group.motions_in_voting_phase.should_not include(motion)
    end
  end

  describe "motions_closed" do
    it "should return motions that belong to the group and are in phase 'voting'" do
      motion.close_voting!
      @group = motion.group
      @group.motions_closed.should include(motion)
    end

    it "should not return motions that belong to the group but are in phase 'closed'" do
      @group = motion.group
      @group.motions_closed.should_not include(motion)
    end
  end

  describe "group.discussions_sorted_for_user(user)" do
    before do
      @user = User.make!
      @group = Group.make!
      @group.add_member!(@user)
    end
    it "returns a list of discussions sorted by last_comment_at" do
      discussion1 = create_discussion :group => @group, :author => @user
      discussion2 = create_discussion :group => @group, :author => @user
      discussion2.add_comment @user, "hi"
      discussion3 = create_discussion :group => @group, :author => @user
      discussion4 = create_discussion :group => @group, :author => @user
      discussion1.add_comment @user, "hi"
      @group.discussions_sorted(@user)[0].should == discussion1
      @group.discussions_sorted(@user)[1].should == discussion4
      @group.discussions_sorted(@user)[2].should == discussion3
      @group.discussions_sorted(@user)[3].should == discussion2
    end
    context "for a group that has subgroups" do
      before do
        subgroup1 = Group.make!(:parent => @group)
        subgroup2 = Group.make!(:parent => @group)
        user2 = User.make!
        @group.add_member! user2
        subgroup1.add_member!(@user)
        @discussion1 = create_discussion :group => subgroup1, :author => @user
        @discussion2 = create_discussion :group => subgroup2, :author => user2
      end
      it "returns discussions for subgroups that the user belongs to" do
        @group.discussions_sorted(@user).should include(@discussion1)
      end
      it "does not return discussions for subgroups the user does not belong to" do
        @group.discussions_sorted(@user).should_not include(@discussion2)
      end
      it "does not return subgroup discussions if user is not specified" do
        @group.discussions_sorted.should_not include(@discussion1)
      end
    end
  end

  # NOTE (Jon): these descriptions seem ridiculous,
  # why did i name the tests this way? mehh.....
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
    it "has an admin email" do
      @group.add_admin!(@user)
      @group.admin_email.should == @user.email
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

  describe "#create_welcome_loomio" do
    before do
      @loomio_helper_bot = User.new
      @loomio_helper_bot.email = "info@loom.io"
      @loomio_helper_bot.name = "loomio helper bot"
      @loomio_helper_bot.password = "password"
      @loomio_helper_bot.save!
      @group = Group.make!
      @group.add_admin!(@loomio_helper_bot)
      @group.create_welcome_loomio
    end

    it "assigns the loomio helper bot as the author" do
      @group.discussions.first.author_id.should == @loomio_helper_bot.id
    end

    it "creates a new discussion" do
      @group.discussions.count.should == 1
    end
    it "creates a new initial comment" do
      @group.discussions.first.comments.count.should == 1
    end
    it "creates a new motion with title" do
      @group.discussions.first.motions.count.should == 1
    end

    context "in a subgroup" do
      before do
        @subgroup = Group.make!
        @subgroup.parent = @group
        @subgroup.save
        @subgroup.create_welcome_loomio
      end

      it "creates a new discussion" do
        @subgroup.discussions.count.should == 1
      end
      it "creates a new initial comment" do
        @subgroup.discussions.first.comments.count.should == 1
      end
      it "creates a new motion with title" do
        @subgroup.discussions.first.motions.count.should == 1
      end
    end

    describe "edit description" do
      before do
        group.stub(:save)
      end
      it "assigns description to the model" do
        group.should_receive(:description=).with "blah"
        xhr :post, :edit_description,
          :id => group.id,
          :description => "blah"
      end
      it "saves the model" do
        group.should_receive :save
        xhr :post, :edit_description,
          :id => group.id,
          :description => "blah"
      end
    end
  end
end
