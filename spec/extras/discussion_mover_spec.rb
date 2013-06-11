require 'spec_helper'

describe DiscussionMover do
  describe "#destination_groups(group, user)" do
    before do
      @user = create :user
      @parent = create :group
      @subgroup = create :group, parent: @parent
      @subgroup1 = create :group, parent: @parent
      @parent.add_admin!(@user)
      @subgroup.add_admin!(@user)
    end

    context "the discussion is in a parent group" do
      it "returns all the subgroups I am an admin of for this group" do
        @subgroup1 = create :group, parent: @parent
        DiscussionMover.destination_groups(@parent, @user).should include([@subgroup.name, @subgroup.id])
        DiscussionMover.destination_groups(@parent, @user).should_not include([@subgroup1.name, @subgroup1.id])
      end
      it "does not return the discussion's group" do
        DiscussionMover.destination_groups(@parent, @user).should_not include([@parent.name, @parent.id])
      end
    end
    context "the discussion is in a subgroup" do
      it "the parent is in the returned list" do
        DiscussionMover.destination_groups(@subgroup, @user).should include([@parent.name, @parent.id])
      end
      it "returns all the subgroups of the parent I am an admin of" do
        @subgroup2 = create :group, parent: @parent
        @subgroup2.add_admin!(@user)
        DiscussionMover.destination_groups(@subgroup, @user).should include([@subgroup2.name, @subgroup2.id])
        DiscussionMover.destination_groups(@subgroup, @user).should_not include([@subgroup1.name, @subgroup1.id])
      end
      it "does not return the discussion's group" do
        DiscussionMover.destination_groups(@subgroup, @user).should_not include([@subgroup.name, @subgroup.id])
      end
    end
  end

  describe "#permission_to_move?(user, origin, destination)" do
    before do
      @user = create :user
      @destination = create :group
      @origin = create :group
    end
    context "user is admin of not destination" do
      it "returns false" do
        DiscussionMover.can_move?(@user, @origin, @destination).should be_false
      end
    end
    context "user is member of origin and destination" do
      it "returns false" do
        @origin.add_member!(@user)
        @destination.add_member!(@user)
        DiscussionMover.can_move?(@user, @origin, @destination).should be_false
      end
    end
    context "user is admin of origin and member of destination" do
      it "returns false" do
        @origin.add_admin!(@user)
        @destination.add_member!(@user)
        DiscussionMover.can_move?(@user, @origin, @destination).should be_false
      end
    end
    context "user is member of origin and admin of destination" do
      it "returns false" do
        @origin.add_member!(@user)
        @destination.add_admin!(@user)
        DiscussionMover.can_move?(@user, @origin, @destination).should be_false
      end
    end
    context "user is admin of origin and destination" do
      it "returns true" do
        @destination.add_admin!(@user)
        @origin.add_admin!(@user)
        DiscussionMover.can_move?(@user, @origin, @destination).should be_true
      end
    end
  end
end

