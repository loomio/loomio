require 'spec_helper'

describe GroupDiscussionsViewer do

  let(:user) { create :user }

  let(:public_group) { create :group, viewable_by: 'everyone' }
  let(:public_subgroup_of_public_group) { create :group, parent: public_group, viewable_by: 'everyone' }
  let(:parent_group_members_subgroup_of_public_group) {create :group, viewable_by: 'parent_group_members', parent: public_group }
  let(:members_only_subgroup_of_public_group) {create :group, parent: public_group, viewable_by: 'members' }

  let(:members_only_group){ create :group, viewable_by: 'members' }
  let(:public_subgroup_of_members_only_group) { create :group, viewable_by: 'everyone', parent: members_only_group }
  let(:parent_group_members_subgroup_of_members_only_group) {create :group, viewable_by: 'parent_group_members', parent: members_only_group }
  let(:members_only_subgroup_of_members_only_group) { create :group, viewable_by: 'members', parent: members_only_group }

  before :all do
    user

    public_group
    public_subgroup_of_public_group
    parent_group_members_subgroup_of_public_group
    members_only_subgroup_of_public_group

    members_only_group
    public_subgroup_of_members_only_group
    parent_group_members_subgroup_of_members_only_group
    members_only_subgroup_of_members_only_group
  end

  describe ".groups_shown_when_viewing_group(group, user)" do
    context "non-member of public_group" do
      before {public_group.reload}
      subject {GroupDiscussionsViewer.groups_shown_when_viewing_group(public_group, user)}
      it {should include public_group}
      it {should include public_subgroup_of_public_group}
      its(:size){should == 2}
    end

    context "non-member of members_only_group" do
      before {public_group.reload}
      subject {GroupDiscussionsViewer.groups_shown_when_viewing_group(members_only_group, user)}
      its(:size){should == 0}
    end

    context "member of public_group" do
      before {public_group.add_member! user}
      subject {GroupDiscussionsViewer.groups_shown_when_viewing_group(public_group, user)}
      it {should include public_group}
      its(:size){should == 1}

      context "member of public_subgroup_of_public_group" do
        before do
          public_subgroup_of_public_group.add_member! user
          public_group.reload
        end
        it {should include public_group}
        it {should include public_subgroup_of_public_group}
        its(:size){should == 2}
      end

      context "member of parent_group_members_subgroup_of_public_group" do
        before do
          parent_group_members_subgroup_of_public_group.add_member! user
          public_group.reload
        end
        it {should include public_group}
        it {should include parent_group_members_subgroup_of_public_group}
        its(:size){should == 2}
      end

      context "member of members_only_subgroup_of_public_group" do
        before do
          members_only_subgroup_of_public_group.add_member! user
          public_group.reload
        end
        it {should include public_group}
        it {should include members_only_subgroup_of_public_group}
        its(:size){should == 2}
      end
    end

    context "member of members_only_group" do
      before {members_only_group.add_member! user}
      subject {GroupDiscussionsViewer.groups_shown_when_viewing_group(members_only_group, user)}
      it {should include members_only_group}
      its(:size){should == 1}

      context "member of public_subgroup_of_members_only_group" do
        before do
          public_subgroup_of_members_only_group.add_member! user
          members_only_group.reload
        end
        it {should include members_only_group}
        it {should include public_subgroup_of_members_only_group}
        its(:size){should == 2}
      end

      context "member of parent_group_members_subgroup_of_members_only_group" do
        before do
          parent_group_members_subgroup_of_members_only_group.add_member! user
          members_only_group.reload
        end
        it {should include members_only_group}
        it {should include parent_group_members_subgroup_of_members_only_group}
        its(:size){should == 2}
      end

      context "member of members_only_subgroup_of_members_only_group" do
        before do
          members_only_subgroup_of_members_only_group.add_member! user
          members_only_group.reload
        end
        it {should include members_only_group}
        it {should include members_only_subgroup_of_members_only_group}
        its(:size){should == 2}
      end
    end
  end
end
