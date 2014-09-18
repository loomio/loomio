require 'rails_helper'

describe GroupsTree do
  describe "for user" do
    let(:parent_group) { create :group, name: 'c' }
    let(:sub_group) { create :group, name: 'b', parent: parent_group }
    let(:mystery_parent_group) { create :group, name: "a mystery" }
    let(:orphaned_sub_group) { create :group, name: 'a', parent: mystery_parent_group }
    let(:user) {create :user}

    before do
      parent_group.add_member! user
      sub_group.add_member! user
      orphaned_sub_group.add_member! user
    end

    describe "to_a" do
      subject do
        GroupsTree.for_user(user).to_a
      end
      it{should == [orphaned_sub_group, parent_group, sub_group]}
    end
  end
end
