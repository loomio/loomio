require 'spec_helper'

describe Queries::VisibleDiscussions do

  #excuse the massive block of definitions.. they clean up the specs. - rg

  let(:user) { create :user }
  let(:public_group) { create :group, viewable_by: 'everyone' }
  let(:discussion_in_public_group) { create :discussion, group: public_group }

  let(:public_subgroup_of_public_group) { create :group, parent: public_group, viewable_by: 'everyone' }
  let(:discussion_in_public_subgroup_of_public_group) { create :discussion, group: public_subgroup_of_public_group }

  let(:parent_group_members_subgroup_of_public_group) {create :group, viewable_by: 'parent_group_members', parent: public_group }
  let(:discussion_in_parent_group_members_subgroup_of_public_group) {create :discussion, group: parent_group_members_subgroup_of_public_group}

  let(:members_only_subgroup_of_public_group) {create :group, parent: public_group, viewable_by: 'members' }
  let(:discussion_in_members_only_subgroup_of_public_group) { create :discussion, group: members_only_subgroup_of_public_group}

  let(:members_only_group){ create :group, viewable_by: 'members' }
  let(:discussion_in_members_only_group) { create :discussion, group: members_only_group }

  let(:public_subgroup_of_members_only_group) { create :group, viewable_by: 'everyone', parent: members_only_group }
  let(:discussion_in_public_subgroup_of_members_only_group) { create :discussion, group: public_subgroup_of_members_only_group }

  let(:parent_group_members_subgroup_of_members_only_group) {create :group, viewable_by: 'parent_group_members', parent: members_only_group }
  let(:discussion_in_parent_group_members_subgroup_of_members_only_group) {create :discussion, group: parent_group_members_subgroup_of_members_only_group}

  let(:members_only_subgroup_of_members_only_group) { create :group, viewable_by: 'members', parent: members_only_group }
  let(:discussion_in_members_only_subgroup_of_members_only_group) { create :discussion, group: members_only_subgroup_of_members_only_group }

  before :all do
    user

    discussion_in_public_group
    discussion_in_public_subgroup_of_public_group
    discussion_in_parent_group_members_subgroup_of_public_group
    discussion_in_members_only_subgroup_of_public_group

    discussion_in_members_only_group
    discussion_in_public_subgroup_of_members_only_group
    discussion_in_parent_group_members_subgroup_of_members_only_group
    discussion_in_members_only_subgroup_of_members_only_group
  end

  describe 'visitor' do
    describe 'views discussions in public_group', focus: true do
      subject do
        Queries::VisibleDiscussions.new(group: public_group, subgroups: true)
      end

      it {should include discussion_in_public_group}
      it {should include discussion_in_public_subgroup_of_public_group}
      its(:size){should == 2} # and no more
    end

    context "views discussions in members only group" do
      subject do
        Queries::VisibleDiscussions.new(group: members_only_group)
      end

      it {should be_empty}
    end
  end

  describe 'non member of public_group showing subgroups' do
    subject do
      Queries::VisibleDiscussions.new(user: user, group: public_group, subgroups: true)
    end

    it {should include discussion_in_public_group}
    it {should include discussion_in_public_subgroup_of_public_group}
    its(:size){should == 2} # and no more

    it 'includes a column indicating it was joined to discussion reader' do
      subject.first['joined_to_discussion_reader'].should == '1'
    end
  end

  describe 'non member of public_group not showing subgroups', focus: true do
    subject do
      Queries::VisibleDiscussions.new(user: user, group: public_group, subgroups: false)
    end

    it {should include discussion_in_public_group}
    its(:size){should == 1} # and no more
  end

  describe "member viewing public_group" do
    before do
      public_group.add_member! user
    end

    subject do
      Queries::VisibleDiscussions.new(user: user, group: public_group, subgroups: true)
    end

    it {should include discussion_in_public_group}
    its(:size){should == 1} # and no more

    context "member viewing public_subgroup_of_public_group" do
      before do
        public_subgroup_of_public_group.add_member! user
      end

      it {should include discussion_in_public_group}
      it {should include discussion_in_public_subgroup_of_public_group}
      its(:size){should == 2} # and no more
    end
  end

  context "member viewing members_only_group" do
    before do
      members_only_group.add_member! user
    end

    subject do
      Queries::VisibleDiscussions.new(user: user, group: members_only_group, subgroups: true)
    end

    it {should include discussion_in_members_only_group}
    its(:size){should == 1}

    context 'member of public_subgroup_of_members_only_group' do
      before { public_subgroup_of_members_only_group.add_member! user}

      it {should include discussion_in_members_only_group}
      it {should include discussion_in_public_subgroup_of_members_only_group }
      its(:size){should == 2}
    end

    context 'member of parent_group_members_subgroup_of_members_only_group' do
      before { parent_group_members_subgroup_of_members_only_group.add_member! user}

      it {should include discussion_in_members_only_group}
      it {should include discussion_in_parent_group_members_subgroup_of_members_only_group }
      its(:size){should == 2}
    end

    context 'member of members_only_subgroup_of_members_only_group' do
      before do
        members_only_subgroup_of_members_only_group.add_member! user
      end

      it {should include discussion_in_members_only_group}
      it {should include discussion_in_members_only_subgroup_of_members_only_group}
      its(:size){should == 2}
    end
  end

  context 'parent_group member viewing public_subgroup_of_members_only_group' do
    before { members_only_group.add_member! user }

    subject do
      Queries::VisibleDiscussions.new(user: user, group: public_subgroup_of_members_only_group)
    end

    context 'non-member of subgroup' do
      it {should include discussion_in_public_subgroup_of_members_only_group}
      its(:size){ should == 1 }
    end

    context 'member of subgroup' do
      before { public_subgroup_of_members_only_group.add_member! user }
      it {should include discussion_in_public_subgroup_of_members_only_group}
      its(:size){ should == 1 }
    end
  end

  context 'parent_group member viewing parent_group_members_subgroup_of_members_only_group' do
    before { members_only_group.add_member! user }

    subject do
      Queries::VisibleDiscussions.new(user: user, group: parent_group_members_subgroup_of_members_only_group)
    end

    context 'non-member of subgroup' do
      it {should include discussion_in_parent_group_members_subgroup_of_members_only_group}
      its(:size){ should == 1 }
    end

    context 'member of subgroup' do
      before { parent_group_members_subgroup_of_members_only_group.add_member! user }

      it {should include discussion_in_parent_group_members_subgroup_of_members_only_group}
      its(:size){ should == 1 }
    end
  end

  context 'parent_group member viewing members_only_subgroup_of_members_only_group' do
    before { members_only_group.add_member! user }

    subject do
      Queries::VisibleDiscussions.new(user: user, group: members_only_subgroup_of_members_only_group)
    end

    context 'non-member of subgroup' do
      its(:size){ should == 0 }
    end

    context 'member of subgroup' do
      before { members_only_subgroup_of_members_only_group.add_member! user }
      it {should include discussion_in_members_only_subgroup_of_members_only_group}
      its(:size){ should == 1 }
    end
  end

  context "user viewing discussions for all their groups" do
    before do
      public_group.add_member! user
    end

    subject do
      Queries::VisibleDiscussions.new(user: user, subgroups: true)
    end

    it {should include discussion_in_public_group}
    its(:size){ should == 1 }
  end

  it "does not return discussions in archived groups" do
    discussion_in_public_group
    public_group.archive!
    Queries::VisibleDiscussions.new.should_not include discussion_in_public_group
  end

  # im not sure I wanna keep these.. anyway look at ActiveRecord::Relation#match for a better way of doing it - rg
  describe "with motions in voting" do
    before do
      create :current_motion, discussion: discussion_in_public_group
    end

    subject do
      Queries::VisibleDiscussions.new(user: user, group: public_group, subgroups: true ).joins(:motions).merge(Motion.voting)
    end

    it {should include discussion_in_public_group}
    its(:size){should == 1}
  end

  describe "#without_current_motions" do
    before do
      create :current_motion, discussion: discussion_in_public_group
    end

    subject do
      Queries::VisibleDiscussions.new(user: user, group: public_group, subgroups: true).
                                  without_current_motions
    end

    it {should_not include discussion_in_public_group}
  end
end
