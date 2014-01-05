require 'spec_helper'

describe GroupDiscussionsViewer do

  let(:user) { create :user }

  def groups_displayed(user: user, group: group)
    GroupDiscussionsViewer.groups_displayed(user: user, group: group)
  end

  describe 'when viewing public group' do
    let(:public_group) { create :group, privacy: 'public', name: 'public group' }
    let(:public_subgroup) { create :group, parent: public_group, privacy: 'public', name: 'public subgroup' }
    let(:private_subgroup) { create :group, parent: public_group, privacy: 'private', name: 'private subgroup' }
    let(:private_vbpm_subgroup) { create :group, privacy: 'private', viewable_by_parent_members: true, parent: public_group, name: 'private vbpm subgroup' }
    let(:hidden_subgroup) { create :group, parent: public_group, privacy: 'hidden', name: 'hidden subgroup' }
    let(:hidden_vbpm_subgroup) { create :group, privacy: 'hidden', viewable_by_parent_members: true, parent: public_group, name: 'hidden vbpm subgroup' }

    subject { groups_displayed(user: user, group: public_group) }

    before do
      public_group
      public_subgroup
      private_subgroup
      hidden_subgroup
    end

    context 'as guest' do
      it { should include public_group,
                          public_subgroup,
                          private_subgroup }

      its(:size){should == 3}
    end

    context 'as member of group' do
      before { public_group.add_member!(user) }

      context 'only' do
        it { should include public_group,
                            public_subgroup,
                            private_subgroup }

        its(:size){should == 3}
      end

      context 'and private subgroup' do
        before { private_subgroup.add_member!(user) }

        it {should include public_group,
                           public_subgroup,
                           private_subgroup }

        its(:size){should == 3}
      end

      context 'and hidden subgroup' do
        before { hidden_subgroup.add_member!(user) }

        it {should include public_group,
                           public_subgroup
                           private_subgroup
                           hidden_subgroup }

        its(:size){should == 4}
      end
    end
  end

  describe 'when viewing private group' do
    let(:private_group) { create :group, privacy: 'private'}
    let(:public_subgroup) { create :group, parent: private_group, privacy: 'public' }
    let(:private_subgroup) { create :group, parent: private_group, privacy: 'private' }
    let(:private_vbpm_subgroup) { create :group, privacy: 'private', viewable_by_parent_members: true, parent: private_group }
    let(:hidden_subgroup) { create :group, parent: private_group, privacy: 'hidden' }
    let(:hidden_vbpm_subgroup) { create :group, privacy: 'hidden', viewable_by_parent_members: true, parent: private_group }

    subject { groups_displayed(user: user,
                               group: private_group) }
    before do
      private_group
      public_subgroup
      private_subgroup
      hidden_subgroup
    end

    context 'as guest' do
      it { should include private_group,
                          public_subgroup,
                          private_subgroup }

      its(:size){ should == 3 }
    end

    context 'as member of group' do
      before {private_group.add_member!(user)}

      context 'only' do
        it { should include private_group,
                            public_subgroup,
                            private_subgroup }

        its(:size){ should == 3 }
      end

      context 'and private subgroup' do
        before { private_subgroup.add_member!(user) }

        it { should include private_group,
                            public_subgroup,
                            private_subgroup }
        its(:size){ should == 3 }
      end

      context 'and hidden subgroup' do
        before { hidden_subgroup.add_member!(user)}

        it { should include private_group,
                            public_subgroup,
                            private_subgroup,
                            hidden_subgroup }

        its(:size){ should == 4 }
      end

      context 'not member of private subgroup, but it is viewable by parent group members' do
        before { private_vbpm_subgroup }
        it { should include private_group,
                            public_subgroup,
                            private_subgroup,
                            private_vbpm_subgroup }

        its(:size) { should == 4 }
      end

      context 'not member of hidden subgroup, but it is viewable by parent group members' do
        before { hidden_vbpm_subgroup }
        it { should include private_group,
                            public_subgroup,
                            private_subgroup,
                            hidden_vbpm_subgroup }

        its(:size) { should == 4 }
      end
    end
  end

  describe 'when viewing hidden group' do
    let(:hidden_group) { create :group, privacy: 'hidden' }
    let(:hidden_subgroup) { create :group, parent: hidden_group, privacy: 'hidden' }
    let(:hidden_vbpm_subgroup) { create :group, privacy: 'hidden', viewable_by_parent_members: true, parent: hidden_group }

    subject { groups_displayed(user: user,
                               group: hidden_group) }

    context 'as guest' do
      its(:size){ should == 0 }
    end

    context 'as member of group' do
      before { hidden_group.add_member!(user) }

      context 'only' do
        it { should == [hidden_group] }
      end

      context 'and hidden subgroup' do
        before { hidden_subgroup.add_member!(user) }

        it { should include hidden_group,
                            hidden_subgroup }

        its(:size) { should == 2 }
      end

      context 'not member of hidden subgroup, but it is viewable by parent group members' do
        before { hidden_vbpm_subgroup }
        it { should include hidden_group,
                            hidden_vbpm_subgroup }

        its(:size) { should == 2 }
      end
    end
  end
end
