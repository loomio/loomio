require_relative '../../app/services/discussion_mover'

describe DiscussionMover do
  let(:user) { double(:user) }
  let(:parent) { double(:group, name: "Parent Group", id: 1) }
  let(:subgroup_admin) { double(:group, parent: parent, name: "Subgroup I'm an admin of", id: 2) }
  let(:subgroup_notadmin) { double(:group, parent: parent, name: "Subgroup I'm not an admin of", id: 3) }

  let(:origin) { double(:group) }
  let(:destination) { double(:group) }

  describe ".destination_groups(group, user)" do
    before do
      parent.stub(:is_a_subgroup?).and_return false
      subgroup_admin.stub(:is_a_subgroup?).and_return true
      parent.stub(:parent).and_return nil
      parent.stub(:subgroups).and_return [subgroup_admin, subgroup_notadmin]
    end

    context "the discussion is in a parent group" do
      before do
        DiscussionMover.stub(:can_move?).with(user, parent, subgroup_admin).and_return true
        DiscussionMover.stub(:can_move?).with(user, parent, subgroup_notadmin).and_return false
      end
      it "returns all the subgroups I am an admin of for this group" do
        DiscussionMover.destination_groups(parent, user).should == [[subgroup_admin.name, subgroup_admin.id]]
        DiscussionMover.destination_groups(parent, user).should_not include [subgroup_notadmin.name, subgroup_notadmin.id]
      end
      it "does not return the discussion's group" do
        DiscussionMover.destination_groups(parent, user).should_not include [parent.name, parent.id]
      end
    end

    context "the discussion is in a subgroup" do
      before do
        DiscussionMover.stub(:can_move?).with(user, subgroup_admin, parent).and_return true
        DiscussionMover.stub(:can_move?).with(user, subgroup_admin, subgroup_notadmin).and_return false
      end
      it "returns all the subgroups of the parent (and the parent group) I am an admin of" do
        DiscussionMover.destination_groups(subgroup_admin, user).should == [[parent.name, parent.id]]
      end
      it "does not return the discussion's group" do
        DiscussionMover.destination_groups(subgroup_admin, user).should_not include [subgroup_notadmin.name, subgroup_notadmin.id]
      end
    end
    context "there are no destinations" do
      it "returns an empty array" do
        DiscussionMover.stub(:can_move?).with(user, subgroup_admin, parent).and_return false
        DiscussionMover.stub(:can_move?).with(user, subgroup_admin, subgroup_notadmin).and_return false

        DiscussionMover.destination_groups(subgroup_admin, user).should == []
      end
    end
  end

  describe ".can_move?(user, origin, destination)" do
    context "user is member of origin and destination" do
      it "returns false" do
        origin.stub_chain(:admins, :include?).with(user).and_return false
        destination.stub_chain(:admins, :include?).with(user).and_return false
        DiscussionMover.can_move?(user, origin, destination).should be_false
      end
    end
    context "user is admin of origin and member of destination" do
      it "returns false" do
        origin.stub_chain(:admins, :include?).with(user).and_return true
        destination.stub_chain(:admins, :include?).with(user).and_return false
        DiscussionMover.can_move?(user, origin, destination).should be_false
      end
    end
    context "user is member of origin and admin of destination" do
      it "returns false" do
        origin.stub_chain(:admins, :include?).with(user).and_return false
        destination.stub_chain(:admins, :include?).with(user).and_return true
        DiscussionMover.can_move?(user, origin, destination).should be_false
      end
    end
    context "user is admin of origin and destination" do
      it "returns true" do
        origin.stub_chain(:admins, :include?).with(user).and_return true
        destination.stub_chain(:admins, :include?).with(user).and_return true
        DiscussionMover.can_move?(user, origin, destination).should be_true
      end
    end
  end
end
