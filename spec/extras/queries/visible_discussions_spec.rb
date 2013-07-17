require 'spec_helper'

describe Queries::VisibleDiscussions do
  let(:non_member) { create :user }
  let(:member) { create :user }
  let(:subgroup_member) { create :user }

  let(:public_group) { create :group, viewable_by: 'everyone' }
  let(:discussion_in_public_group) { create :discussion, group: public_group }

  let(:members_only_group){ create :group, viewable_by: 'members' }
  let(:discussion_in_members_only_group) { create :discussion, group: members_only_group }

  let(:public_subgroup) { create :group, parent: public_group, viewable_by: 'everyone' }
  let(:discussion_in_public_subgroup) { create :discussion, group: public_subgroup }

  let(:parent_group_members_subgroup) {create :group, viewable_by: 'parent_group_members', parent: public_group }
  let(:discussion_in_parent_group_members_subgroup) {create :discussion, group: parent_group_members_subgroup}

  let(:members_only_subgroup) {create :group, parent: public_group, viewable_by: 'members' }
  let(:discussion_in_members_only_subgroup) { create :discussion, group: members_only_subgroup}

  let(:archived_public_group) { create :group, viewable_by: 'everyone' }
  let(:discussion_in_archived_public_group) { create :discussion, group: archived_public_group }

  before :all do
    # Add members to groups
    non_member
    public_group.add_member! member
    public_group.add_member! subgroup_member
    members_only_group.add_member! member
    members_only_group.add_member! subgroup_member

    # Add subgroup_member to subgroups
    public_subgroup.add_member! subgroup_member
    parent_group_members_subgroup.add_member! subgroup_member
    members_only_subgroup.add_member! subgroup_member

    # Generate the discussions
    discussion_in_public_group
    discussion_in_members_only_group
    discussion_in_public_subgroup
    discussion_in_parent_group_members_subgroup
    discussion_in_members_only_subgroup
    discussion_in_archived_public_group

    # Archive the group
    archived_public_group.archive!
  end

  describe ".new" do
    subject{Queries::VisibleDiscussions.new}
    its(:size){should == 0}
  end

  describe ".new(groups: [public_group])" do
    subject{Queries::VisibleDiscussions.new(groups: [public_group])}
    it {should include discussion_in_public_group}
    its(:size){should == 1}
  end

  describe ".new(groups: [members_only_group])" do
    subject{Queries::VisibleDiscussions.new(groups: [members_only_group])}
    its(:size){should == 0}
  end

  describe ".new(groups: [public_subgroup])" do
    subject{Queries::VisibleDiscussions.new(groups: [public_subgroup])}
    it {should include discussion_in_public_subgroup}
    its(:size){should == 1}
  end

  describe ".new(groups: [parent_group_members_subgroup])" do
    subject{Queries::VisibleDiscussions.new(groups: [parent_group_members_subgroup])}
    its(:size){should == 0}
  end

  describe ".new(groups: [members_only_subgroup])" do
    subject{Queries::VisibleDiscussions.new(groups: [members_only_subgroup])}
    its(:size){should == 0}
  end

  describe ".new(groups: [archived_public_group])" do
    subject{Queries::VisibleDiscussions.new(groups: [archived_public_group])}
    its(:size){should == 0}
  end

  describe ".new(user: non_member)" do
    subject{Queries::VisibleDiscussions.new(user: non_member)}
    its(:size){should == 0}
  end

  describe ".new(user: non_member, groups: [public_group])" do
    subject{Queries::VisibleDiscussions.new(user: non_member, groups: [public_group])}
    it {should include discussion_in_public_group}
    its(:size){should == 1}
  end

  describe ".new(user: non_member, groups: [members_only_group])" do
    subject{Queries::VisibleDiscussions.new(user: non_member, groups: [members_only_group])}
    its(:size){should == 0}
  end

  describe ".new(user: non_member, groups: [public_subgroup])" do
    subject{Queries::VisibleDiscussions.new(user: non_member, groups: [public_subgroup])}
    it {should include discussion_in_public_subgroup}
    its(:size){should == 1}
  end

  describe ".new(user: non_member, groups: [parent_group_members_subgroup])" do
    subject{Queries::VisibleDiscussions.new(user: non_member, groups: [parent_group_members_subgroup])}
    its(:size){should == 0}
  end

  describe ".new(user: non_member, groups: [members_only_subgroup])" do
    subject{Queries::VisibleDiscussions.new(user: non_member, groups: [members_only_subgroup])}
    its(:size){should == 0}
  end

  describe ".new(user: member)" do
    subject{Queries::VisibleDiscussions.new(user: member)}
    it {should include discussion_in_public_group}
    it {should include discussion_in_members_only_group}
    its(:size){should == 2}
  end

  describe ".new(user: member, groups: [public_group])" do
    subject{Queries::VisibleDiscussions.new(user: member, groups: [public_group])}
    it {should include discussion_in_public_group}
    its(:size){should == 1}
  end

  describe ".new(user: member, groups: [members_only_group])" do
    subject{Queries::VisibleDiscussions.new(user: member, groups: [members_only_group])}
    it {should include discussion_in_members_only_group}
    its(:size){should == 1}
  end

  describe ".new(user: subgroup_member, groups: [public_subgroup])" do
    subject{Queries::VisibleDiscussions.new(user: subgroup_member, groups: [public_subgroup])}
    it{should include discussion_in_public_subgroup}
    its(:size){should == 1}
  end

  describe ".new(user: subgroup_member, groups: [parent_group_members_subgroup])" do
    subject{Queries::VisibleDiscussions.new(user: subgroup_member, groups: [parent_group_members_subgroup])}
    it{should include discussion_in_parent_group_members_subgroup}
    its(:size){should == 1}
  end

  describe ".new(user: subgroup_member, groups: [members_only_subgroup])" do
    subject{Queries::VisibleDiscussions.new(user: subgroup_member, groups: [members_only_subgroup])}
    it{should include discussion_in_members_only_subgroup}
    its(:size){should == 1}
  end

  describe ".new(user: parent_group_member, groups: [public_subgroup])" do
    subject{Queries::VisibleDiscussions.new(user: member, groups: [public_subgroup])}
    it{should include discussion_in_public_subgroup}
    its(:size){should == 1}
  end

  describe ".new(user: parent_group_member, groups: [parent_group_members_subgroup])" do
    subject{Queries::VisibleDiscussions.new(user: member, groups: [parent_group_members_subgroup])}
    it{should include discussion_in_parent_group_members_subgroup}
    its(:size){should == 1}
  end

  describe ".new(user: parent_group_member, groups: [members_only_subgroup])" do
    subject{Queries::VisibleDiscussions.new(user: member, groups: [members_only_subgroup])}
    its(:size){should == 0}
  end

  describe "#with_open_motions" do
    before do
      @discussion_with_motion_in_public_group = create :discussion, group: public_group
      @motion = create :current_motion, discussion: @discussion_with_motion_in_public_group
    end

    subject do
      Queries::VisibleDiscussions.new(user: non_member, groups: [public_group]).with_open_motions
    end

    it {should include @discussion_with_motion_in_public_group}
    its(:size){should == 1}
  end

  describe "#without_open_motions" do
    before do
      @discussion_with_motion_in_public_group = create :discussion, group: public_group
      @motion = create :current_motion, discussion: @discussion_with_motion_in_public_group
    end

    subject do
      Queries::VisibleDiscussions.new(groups: [public_group]).without_open_motions
    end

    it {should_not include @discussion_with_motion_in_public_group}
  end
end
