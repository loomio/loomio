require 'spec_helper'

describe DiscussionsQuery do
  context "getting a group's discussions for a member" do
    let(:user) { create :user }
    let(:group) { create :group, :creator => user }

    it "returns the group's discussions" do
      discussion = create :discussion, :group => group
      discussions = DiscussionsQuery.new(user, group)
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
      discussions = DiscussionsQuery.new(user, group)
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
      discussions = DiscussionsQuery.new(user, group)
      discussions.should_not include(subgroup_discussion1)
      discussions.should_not include(subgroup_discussion2)
      discussions.should_not include(subgroup_discussion3)
    end
  end

  context "getting a public group's discussions for an observer" do
    let(:user) { nil }
    let(:group) { create :group }

    it "returns the group's discussions" do
      discussion = create :discussion, :group => group
      discussions = DiscussionsQuery.new(user, group)
      discussions.should include(discussion)
    end

    it "returns public subgroup discussions" do
      subgroup = create :group, :parent => group
      subgroup_discussion = create :discussion, :group => subgroup
      discussions = DiscussionsQuery.new(user, group)
      discussions.should include(subgroup_discussion)
    end

    it "doesn't return private subgroup discussions" do
      subgroup1 = create :group, :parent => group,
                  :viewable_by => :parent_group_members
      subgroup2 = create :group, :parent => group,
                  :viewable_by => :members
      subgroup1_discussion = create :discussion, :group => subgroup1
      subgroup2_discussion = create :discussion, :group => subgroup2
      discussions = DiscussionsQuery.new(user, group)
      discussions.should_not include(subgroup1_discussion)
      discussions.should_not include(subgroup2_discussion)
    end
  end
end