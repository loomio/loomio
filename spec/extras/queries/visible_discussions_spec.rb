require 'spec_helper'

describe Queries::VisibleDiscussions do
  let(:user) { create :user }
  let(:group) { create :group, :creator => user }

  it "::for sorts discussions by latest comment time" do
    Time.stub(:now).and_return Time.new(2012, 1, 1, 1)
    discussion1 = create :discussion, :group => group, :author => user
    Time.stub(:now).and_return Time.new(2012, 1, 1, 2)
    discussion2 = create :discussion, :group => group, :author => user
    Time.stub(:now).and_return Time.new(2012, 1, 1, 3)
    discussion3 = create :discussion, :group => group, :author => user
    Time.stub(:now).and_return Time.new(2012, 1, 1, 4)
    discussion2.add_comment(user, "hi", false)
    discussions = Queries::VisibleDiscussions.for(group)
    discussions[0].should == discussion2
    discussions[1].should == discussion3
    discussions[2].should == discussion1
  end

  describe "::for(group)" do
    context "public group" do
      it "returns the group's discussions" do
        discussion = create :discussion, :group => group
        discussions = Queries::VisibleDiscussions.for(group)
        discussions.should include(discussion)
      end

      it "returns public subgroup discussions" do
        subgroup = create :group, :parent => group
        subgroup_discussion = create :discussion, :group => subgroup
        discussions = Queries::VisibleDiscussions.for(group)
        discussions.should include(subgroup_discussion)
      end

      it "doesn't return private subgroup discussions" do
        subgroup1 = create :group, :parent => group,
                           :viewable_by => :parent_group_members
        subgroup2 = create :group, :parent => group,
                           :viewable_by => :members
        subgroup1_discussion = create :discussion, :group => subgroup1
        subgroup2_discussion = create :discussion, :group => subgroup2
        discussions = Queries::VisibleDiscussions.for(group)
        discussions.should_not include(subgroup1_discussion)
        discussions.should_not include(subgroup2_discussion)
      end
    end

    context "private group" do
      let(:group) { create :group, :viewable_by => :members }

      it "returns no discussions" do
        discussion = create :discussion, :group => group
        discussions = Queries::VisibleDiscussions.for(group)
        discussions.should be_empty
      end
    end

    context "visible-to-parent group" do
      let(:group) { create :group, :viewable_by => :parent_group_members }

      it "returns no discussions" do
        discussion = create :discussion, :group => group
        discussions = Queries::VisibleDiscussions.for(group)
        discussions.should be_empty
      end
    end
  end

  describe "::for(group, member)" do
    it "returns the group's discussions" do
      discussion = create :discussion, :group => group
      discussions = Queries::VisibleDiscussions.for(group, user)
      discussions.should include(discussion)
    end

    it "returns discussions for subgroups the user belongs to" do
      subgroup1 = create :group, :creator => user, :parent => group,
                         :viewable_by => :everyone
      subgroup2 = create :group, :creator => user, :parent => group,
                         :viewable_by => :parent_group_members
      subgroup3 = create :group, :creator => user, :parent => group,
                         :viewable_by => :members
      subgroup_discussion1 = create :discussion, :group => subgroup1
      subgroup_discussion2 = create :discussion, :group => subgroup2
      subgroup_discussion3 = create :discussion, :group => subgroup3
      discussions = Queries::VisibleDiscussions.for(group, user)
      discussions.should include(subgroup_discussion1)
      discussions.should include(subgroup_discussion2)
      discussions.should include(subgroup_discussion3)
    end

    it "doesn't return discussions for subgroups the user doesn't belong to" do
      subgroup1 = create :group, :parent => group,
                         :viewable_by => :everyone
      subgroup2 = create :group, :parent => group,
                         :viewable_by => :parent_group_members
      subgroup3 = create :group, :parent => group,
                         :viewable_by => :members
      subgroup_discussion1 = create :discussion, :group => subgroup1
      subgroup_discussion2 = create :discussion, :group => subgroup2
      subgroup_discussion3 = create :discussion, :group => subgroup3
      discussions = Queries::VisibleDiscussions.for(group, user)
      discussions.should_not include(subgroup_discussion1)
      discussions.should_not include(subgroup_discussion2)
      discussions.should_not include(subgroup_discussion3)
    end
  end

  describe "::for(group, non_member)" do
    let(:user) { create :user }
    let(:group) { create :group }

    it "returns the group's discussions" do
      discussion = create :discussion, :group => group
      discussions = Queries::VisibleDiscussions.for(group, user)
      discussions.should include(discussion)
    end

    it "doesn't return discussions if group is private" do
      group.update_attribute(:viewable_by, :members)
      discussion = create :discussion, :group => group
      discussions = Queries::VisibleDiscussions.for(group, user)
      discussions.should_not include(discussion)
    end

    it "returns discussions for public subgroups" do
      subgroup = create :group, :parent => group, :viewable_by => :everyone
      subgroup_discussion = create :discussion, :group => subgroup
      discussions = Queries::VisibleDiscussions.for(group, user)
      discussions.should include(subgroup_discussion)
    end

    it "doesn't return discussions for private subgroups" do
      subgroup = create :group, :parent => group,
                         :viewable_by => :parent_group_members
      subgroup2 = create :group, :parent => group,
                         :viewable_by => :members
      subgroup_discussion = create :discussion, :group => subgroup
      subgroup_discussion2 = create :discussion, :group => subgroup2
      discussions = Queries::VisibleDiscussions.for(group, user)
      discussions.should_not include(subgroup_discussion)
      discussions.should_not include(subgroup_discussion2)
    end
  end

  describe "::for(subgroup, parent_group_member)" do
    let(:user) { create :user }
    let(:parent_group) { create :group, :creator => user }
    let(:subgroup) { create :group, :parent => parent_group }
    let(:discussion) { create :discussion, :group => subgroup }

    context "public subgroup" do
      it "returns the subgroup's discussions" do
        discussions = Queries::VisibleDiscussions.for(subgroup, user)
        discussions.should include(discussion)
      end
    end

    context "private subgroup" do
      it "doesn't return discussions" do
        subgroup.update_attribute(:viewable_by, :members)
        discussions = Queries::VisibleDiscussions.for(subgroup, user)
        discussions.should_not include(discussion)
      end
    end

    context "visible-to-parent subgroup" do
      it "returns the subgroup's discussions" do
        subgroup.update_attribute(:viewable_by, :parent_group_members)
        discussions = Queries::VisibleDiscussions.for(subgroup, user)
        discussions.should include(discussion)
      end
    end
  end

  describe "#with_current_motions" do
    it "only returns discussions with current motions" do
      group = create :group
      discussion = create :discussion, :group => group
      discussion_with_motion = create :discussion, :group => group
      motion = create :motion, :discussion => discussion_with_motion
      discussions = Queries::VisibleDiscussions.for(group).with_current_motions
      discussions.should_not include(discussion)
      discussions.should include(discussion_with_motion)
    end
  end

  shared_context "motions with votes" do
    before do
      @user = create :user
      @group = create :group
      @group.add_member! @user
      @discussion_with_no_vote = create :discussion, :group => @group, :author => @user
      motion = create :motion, :discussion => @discussion_with_no_vote, :author => @user
      @discussion_with_vote = create :discussion, :group => @group, :author => @user
      motion_with_vote = create :motion, :discussion => @discussion_with_vote, :author => @user
      vote = Vote.new position: "yes"
      vote.motion = motion_with_vote
      vote.user = @user
      vote.save
    end
  end

  describe "#with_current_motions_user_has_voted_on" do
    include_context "motions with votes"
    it "returns only discussions that have a current motion that user has voted on" do
      discussions = Queries::VisibleDiscussions.for(@group, @user)
      discussions = discussions.with_current_motions_user_has_voted_on
      discussions.should include(@discussion_with_vote)
      discussions.should_not include(@discussion_with_no_vote)
    end

    it "returns no discussions if user is nil" do
      discussions = Queries::VisibleDiscussions.for(@group, nil)
      discussions = discussions.with_current_motions_user_has_voted_on
      discussions.should be_empty
    end
  end

  describe "#with_current_motions_user_has_not_voted_on" do
    include_context "motions with votes"
    it "returns only discussions that have a current motion that user has not voted on" do
      discussions = Queries::VisibleDiscussions.for(@group, @user)
      discussions = discussions.with_current_motions_user_has_not_voted_on
      discussions.should include(@discussion_with_no_vote)
      discussions.should_not include(@discussion_with_vote)
    end

    it "returns all discussions with motions if user is nil" do
      discussions = Queries::VisibleDiscussions.for(@group, nil)
      discussions = discussions.with_current_motions_user_has_not_voted_on
      discussions.should include(@discussion_with_no_vote)
      discussions.should include(@discussion_with_vote)
    end

    it "returns all discussions with motions if user is not a member" do
      discussions = Queries::VisibleDiscussions.for(@group, create(:user))
      discussions = discussions.with_current_motions_user_has_not_voted_on
      discussions.should include(@discussion_with_no_vote)
      discussions.should include(@discussion_with_vote)
    end
  end

  describe "#without_current_motions" do
    it "returns only discussions without a current motion" do
      discussion = create :discussion, :group => group
      discussion2 = create :discussion, :group => group
      motion = create :motion, :discussion => discussion2
      discussions = Queries::VisibleDiscussions.for(group).without_current_motions
      discussions.should include(discussion)
      discussions.should_not include(discussion2)
    end
  end
end