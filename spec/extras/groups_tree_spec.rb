require 'spec_helper'

describe GroupsTree do
  describe "#depth_first_traversal" do
    let(:user) { create(:user) }
    let(:group1) { create(:group, name: "group1") }
    let(:group2) { create(:group, name: "group2") }
    let(:subgroup1) { create(:group, name: "subgroup1", parent: group1) }
    let(:subgroup2) { create(:group, name: "subgroup2", parent: group1) }
    let(:tree) { GroupsTree.for_user(user) }

    it "doesnt yield if user has no groups" do
      tree.count.should == 0
    end

    it "yields user's groups" do
      group1.add_member!(user)
      group2.add_member!(user)
      traversal = tree.depth_first_traversal
      traversal.next.should == group1
      traversal.next.should == group2
      tree.should_not include(subgroup1)
    end

    it "yields user's groups and subgroups" do
      # group1
      # - subgroup1
      # group2
      group1.add_member!(user)
      group2.add_member!(user)
      subgroup1.add_member!(user)
      traversal = tree.depth_first_traversal
      traversal.next.should == group1
      traversal.next.should == subgroup1
      traversal.next.should == group2
      tree.should_not include(subgroup2)
    end
  end
end
