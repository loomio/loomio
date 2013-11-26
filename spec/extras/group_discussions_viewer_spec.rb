require 'spec_helper'

describe GroupDiscussionsViewer do

  let(:user) { create :user }

  let(:public_group) { create :group, privacy: 'public' }
  let(:public_subgroup_of_public_group) { create :group, parent: public_group, privacy: 'public' }

  let(:parent_members_subgroup_of_public_group) {create :group, privacy: 'parent_group_members', parent: public_group }
  let(:secret_subgroup_of_public_group) {create :group, parent: public_group, privacy: 'secret' }

  let(:secret_group){ create :group, privacy: 'secret' }
  let(:public_subgroup_of_secret_group) { create :group, privacy: 'public', parent: secret_group }
  let(:parent_members_subgroup_of_secret_group) {create :group, privacy: 'parent_group_members', parent: secret_group }
  let(:secret_subgroup_of_secret_group) { create :group, privacy: 'secret', parent: secret_group }

  def groups_displayed(user: user, group: group)
    GroupDiscussionsViewer.groups_displayed(user: user, group: group)
  end

  describe 'groups_displayed when viewing public group' do
    before do
      public_group
      public_subgroup_of_public_group
      parent_members_subgroup_of_public_group
      secret_subgroup_of_public_group
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
        secret_subgroup_of_public_group.add_member!(user)
      end

      it {should include public_group, 
                         secret_subgroup_of_public_group }

      its(:size){should == 2}
    end
  end

  describe 'groups_displayed when viewing members only group' do
    before do
      secret_group
      public_subgroup_of_secret_group
      parent_members_subgroup_of_secret_group
      secret_subgroup_of_secret_group
    end

    subject { groups_displayed(user: user, 
                               group: secret_group) }

    context 'as guest' do
      its(:size){ should == 0 }
    end

    context 'as member of top only' do
      before { secret_group.add_member!(user) }

      it { should == [secret_group] }
    end

    context 'as member of top and subgroup' do
      before do
        secret_group.add_member!(user)
        secret_subgroup_of_secret_group.add_member!(user)
      end

      it { should include secret_group, 
                          secret_subgroup_of_secret_group }
      its(:size) { should == 2 }
    end

    context 'as member of top and parent_members subgroup' do
      before do
        secret_group.add_member!(user)
        parent_members_subgroup_of_secret_group.add_member!(user)
      end

      it { should include secret_group, 
                          parent_members_subgroup_of_secret_group }
      its(:size) { should == 2 }
    end
  end

  describe 'viewing parent_members subgroup' do
    before do
      secret_group
      parent_members_subgroup_of_secret_group
      secret_group.add_member!(user)
      parent_members_subgroup_of_secret_group.add_member!(user)
    end

    subject { groups_displayed(user: user, 
                               group: parent_members_subgroup_of_secret_group) }

    it {should == [parent_members_subgroup_of_secret_group] }
  end
end
