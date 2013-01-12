require 'spec_helper'

describe DiscussionsQuery do
  describe "::for(group)" do
    let(:user) { nil }
    let(:group) { create :group }

    it "returns the group's discussions" do
      discussion = create :discussion, :group => group
      discussions = DiscussionsQuery.for(group, user)
      discussions.should include(discussion)
    end

    it "returns public subgroup discussions" do
      subgroup = create :group, :parent => group
      subgroup_discussion = create :discussion, :group => subgroup
      discussions = DiscussionsQuery.for(group, user)
      discussions.should include(subgroup_discussion)
    end

    it "doesn't return private subgroup discussions" do
      subgroup1 = create :group, :parent => group,
                  :viewable_by => :parent_group_members
      subgroup2 = create :group, :parent => group,
                  :viewable_by => :members
      subgroup1_discussion = create :discussion, :group => subgroup1
      subgroup2_discussion = create :discussion, :group => subgroup2
      discussions = DiscussionsQuery.for(group, user)
      discussions.should_not include(subgroup1_discussion)
      discussions.should_not include(subgroup2_discussion)
    end
  end

  describe "::for(group, user)" do
    let(:user) { create :user }
    let(:group) { create :group, :creator => user }

    it "returns the group's discussions" do
      discussion = create :discussion, :group => group
      discussions = DiscussionsQuery.for(group, user)
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
      discussions = DiscussionsQuery.for(group, user)
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
      discussions = DiscussionsQuery.for(group, user)
      discussions.should_not include(subgroup_discussion1)
      discussions.should_not include(subgroup_discussion2)
      discussions.should_not include(subgroup_discussion3)
    end
  end

  describe "#with_current_motions" do
    it "only returns discussions with current motions" do
      group = create :group
      discussion = create :discussion, :group => group
      discussion_with_motion = create :discussion, :group => group
      motion = create :motion, :discussion => discussion_with_motion
      discussions = DiscussionsQuery.for(group).with_current_motions
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
      motion = create :motion, discussion: @discussion_with_no_vote, author: @user
      @discussion_with_vote = create :discussion, :group => @group, :author => @user
      motion_with_vote = create :motion, discussion: @discussion_with_vote, author: @user
      vote = Vote.new position: "yes"
      vote.motion = motion_with_vote
      vote.user = @user
      vote.save
    end
  end

  describe "#with_current_motions_user_has_voted_on" do
    include_context "motions with votes"
    it "only returns discussions that have a current motion that user has voted on" do
      discussions = DiscussionsQuery.for(@group, @user)
      discussions = discussions.with_current_motions_user_has_voted_on
      discussions.should include(@discussion_with_vote)
      discussions.should_not include(@discussion_with_no_vote)
    end
  end

  describe "discussions_with_current_motion_not_voted_on(user)" do
    include_context "motions with votes"
    it "only returns discussions that have a current motion that user has not voted on" do
      discussions = DiscussionsQuery.for(@group, @user)
      discussions = discussions.with_current_motions_user_has_not_voted_on
      discussions.should include(@discussion_with_no_vote)
      discussions.should_not include(@discussion_with_vote)
    end
  end
end