require 'spec_helper'

describe GroupDiscussionsViewer do

  let(:user) { create :user }

  let(:public_group) { create :group, viewable_by: 'everyone' }
  let(:public_subgroup_of_public_group) { create :group, parent: public_group, viewable_by: 'everyone' }

  let(:parent_members_subgroup_of_public_group) {create :group, viewable_by: 'parent_group_members', parent: public_group }
  let(:members_only_subgroup_of_public_group) {create :group, parent: public_group, viewable_by: 'members' }

  let(:members_only_group){ create :group, viewable_by: 'members' }
  let(:public_subgroup_of_members_only_group) { create :group, viewable_by: 'everyone', parent: members_only_group }
  let(:parent_members_subgroup_of_members_only_group) {create :group, viewable_by: 'parent_group_members', parent: members_only_group }
  let(:members_only_subgroup_of_members_only_group) { create :group, viewable_by: 'members', parent: members_only_group }

  def groups_displayed(user: user, group: group)
    GroupDiscussionsViewer.groups_displayed(user: user, group: group)
  end

  describe 'groups_displayed when viewing public group' do
    before do
      public_group
      public_subgroup_of_public_group
      parent_members_subgroup_of_public_group
      members_only_subgroup_of_public_group
    end

    subject { groups_displayed(user: user, group: public_group) }

    context 'as guest' do
      # when guest, we also show public subgroups
      it {should include public_group, 
                         public_subgroup_of_public_group}
      its(:size){should == 2}
    end

    context 'as member of top only' do
      before { public_group.add_member!(user) }

      # once you are a member of a group we dont show subgroups 
      # unless you belong to them

      it {should == [public_group]}
    end

    context 'as member of top and subgroup' do
      before do
        public_group.add_member!(user)
        members_only_subgroup_of_public_group.add_member!(user)
      end

      it {should include public_group, 
                         members_only_subgroup_of_public_group }

      its(:size){should == 2}
    end
  end

  describe 'groups_displayed when viewing members only group' do
    before do
      members_only_group
      public_subgroup_of_members_only_group
      parent_members_subgroup_of_members_only_group
      members_only_subgroup_of_members_only_group
    end

    subject { groups_displayed(user: user, 
                               group: members_only_group) }

    context 'as guest' do
      its(:size){ should == 0 }
    end

    context 'as member of top only' do
      before { members_only_group.add_member!(user) }

      it { should == [members_only_group] }
    end

    context 'as member of top and subgroup' do
      before do
        members_only_group.add_member!(user)
        members_only_subgroup_of_members_only_group.add_member!(user)
      end

      it { should include members_only_group, 
                          members_only_subgroup_of_members_only_group }
      its(:size) { should == 2 }
    end

    context 'as member of top and parent_members subgroup' do
      before do
        members_only_group.add_member!(user)
        parent_members_subgroup_of_members_only_group.add_member!(user)
      end

      it { should include members_only_group, 
                          parent_members_subgroup_of_members_only_group }
      its(:size) { should == 2 }
    end
  end

  describe 'viewing parent_members subgroup' do
    before do
      members_only_group
      parent_members_subgroup_of_members_only_group
      members_only_group.add_member!(user)
      parent_members_subgroup_of_members_only_group.add_member!(user)
    end

    subject { groups_displayed(user: user, 
                               group: parent_members_subgroup_of_members_only_group) }

    it {should == [parent_members_subgroup_of_members_only_group] }
  end
end
