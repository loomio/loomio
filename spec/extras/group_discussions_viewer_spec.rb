require 'spec_helper'

describe GroupDiscussionsViewer do

  let(:user) { create :user }
  let(:non_member) { create :user }
  let(:member) { create :user }
  let(:subgroup_member) { create :user }

  let(:public_group) { create :group, viewable_by: 'everyone' }
  let(:public_subgroup_of_public_group) { create :group, parent: public_group, viewable_by: 'everyone' }
  let(:parent_members_subgroup_of_public_group) {create :group, viewable_by: 'parent_group_members', parent: public_group }
  let(:members_only_subgroup_of_public_group) {create :group, parent: public_group, viewable_by: 'members' }

  let(:members_only_group){ create :group, viewable_by: 'members' }
  let(:public_subgroup_of_members_only_group) { create :group, viewable_by: 'everyone', parent: members_only_group }
  let(:parent_members_subgroup_of_members_only_group) {create :group, viewable_by: 'parent_group_members', parent: members_only_group }
  let(:members_only_subgroup_of_members_only_group) { create :group, viewable_by: 'members', parent: members_only_group }

  before :all do
    non_member
    public_group.add_member! member
    public_group.add_member! subgroup_member
    members_only_group.add_member! member
    members_only_group.add_member! subgroup_member

    public_subgroup_of_public_group.add_member! subgroup_member
    parent_members_subgroup_of_public_group.add_member! subgroup_member
    members_only_subgroup_of_public_group.add_member! subgroup_member

    public_subgroup_of_members_only_group.add_member! subgroup_member
    parent_members_subgroup_of_members_only_group.add_member! subgroup_member
    members_only_subgroup_of_members_only_group.add_member! subgroup_member
  end

  describe ".groups_shown_when_viewing_group(user: non_member, group: public_group)" do
    subject {GroupDiscussionsViewer.groups_shown_when_viewing_group(group: public_group, user: non_member)}
    it {should include public_group}
    it {should include public_subgroup_of_public_group}
    its(:size){should == 2}
  end

  describe ".groups_shown_when_viewing_group(user: non_member, group: members_only_group)" do
    subject {GroupDiscussionsViewer.groups_shown_when_viewing_group(user: non_member, group: members_only_group)}
    its(:size){should == 0}
  end

  context ".groups_shown_when_viewing_group(user: member, group: public_group)" do
    subject {GroupDiscussionsViewer.groups_shown_when_viewing_group(user: member, group: public_group)}
    it {should include public_group}
    its(:size){should == 1}
  end

  context ".groups_shown_when_viewing_group(user: member, group: members_only_group)" do
    subject {GroupDiscussionsViewer.groups_shown_when_viewing_group(user: member, group: members_only_group)}
    it {should include members_only_group}
    its(:size){should == 1}
  end

  context ".groups_shown_when_viewing_group(user: subgroup_member, group: public_group)" do
    subject {GroupDiscussionsViewer.groups_shown_when_viewing_group(user: subgroup_member, group: public_group)}
    it {should include public_group}
    it {should include public_subgroup_of_public_group}
    it {should include parent_members_subgroup_of_public_group}
    it {should include members_only_subgroup_of_public_group}
    its(:size){should == 4}
  end

  context ".groups_shown_when_viewing_group(user: subgroup_member, group: members_only_group)" do
    subject {GroupDiscussionsViewer.groups_shown_when_viewing_group(user: subgroup_member, group: members_only_group)}
    it {should include members_only_group}
    it {should include public_subgroup_of_members_only_group}
    it {should include parent_members_subgroup_of_members_only_group}
    it {should include members_only_subgroup_of_members_only_group}
    its(:size){should == 4}
  end

  context ".groups_shown_when_viewing_group(user: subgroup_member, group: public_subgroup_of_public_group)" do
    subject {GroupDiscussionsViewer.groups_shown_when_viewing_group(user: subgroup_member, group: public_subgroup_of_public_group)}
    it {should include public_subgroup_of_public_group}
    its(:size){should == 1}
  end

  context ".groups_shown_when_viewing_group(user: subgroup_member, group: parent_members_subgroup_of_public_group)" do
    subject {GroupDiscussionsViewer.groups_shown_when_viewing_group(user: subgroup_member, group: parent_members_subgroup_of_public_group)}
    it {should include parent_members_subgroup_of_public_group}
    its(:size){should == 1}
  end

  context ".groups_shown_when_viewing_group(user: subgroup_member, group: members_only_subgroup_of_public_group)" do
    subject {GroupDiscussionsViewer.groups_shown_when_viewing_group(user: subgroup_member, group: members_only_subgroup_of_public_group)}
    it {should include members_only_subgroup_of_public_group}
    its(:size){should == 1}
  end

  context ".groups_shown_when_viewing_group(user: subgroup_member, group: public_subgroup_of_members_only_group)" do
    subject {GroupDiscussionsViewer.groups_shown_when_viewing_group(user: subgroup_member, group: public_subgroup_of_members_only_group)}
    it {should include public_subgroup_of_members_only_group}
    its(:size){should == 1}
  end

  context ".groups_shown_when_viewing_group(user: subgroup_member, group: parent_members_subgroup_of_members_only_group)" do
    subject {GroupDiscussionsViewer.groups_shown_when_viewing_group(user: subgroup_member, group: parent_members_subgroup_of_members_only_group)}
    it {should include parent_members_subgroup_of_members_only_group}
    its(:size){should == 1}
  end

  context ".groups_shown_when_viewing_group(user: subgroup_member, group: members_only_subgroup_of_members_only_group)" do
    subject {GroupDiscussionsViewer.groups_shown_when_viewing_group(user: subgroup_member, group: members_only_subgroup_of_members_only_group)}
    it {should include members_only_subgroup_of_members_only_group}
    its(:size){should == 1}
  end
end
