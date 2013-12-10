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
    let(:secret_subgroup) { create :group, parent: public_group, privacy: 'secret', name: 'secret subgroup' }
    let(:secret_vbpm_subgroup) { create :group, privacy: 'secret', viewable_by_parent_members: true, parent: public_group, name: 'secret vbpm subgroup' }

    subject { groups_displayed(user: user, group: public_group) }

    before do
      public_group
      public_subgroup
      private_subgroup
      secret_subgroup
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

      context 'and secret subgroup' do
        before { secret_subgroup.add_member!(user) }

        it {should include public_group,
                           public_subgroup
                           private_subgroup
                           secret_subgroup }

        its(:size){should == 4}
      end
    end
  end

  describe 'when viewing private group' do
    let(:private_group) { create :group, privacy: 'private'}
    let(:public_subgroup) { create :group, parent: private_group, privacy: 'public' }
    let(:private_subgroup) { create :group, parent: private_group, privacy: 'private' }
    let(:private_vbpm_subgroup) { create :group, privacy: 'private', viewable_by_parent_members: true, parent: private_group }
    let(:secret_subgroup) { create :group, parent: private_group, privacy: 'secret' }
    let(:secret_vbpm_subgroup) { create :group, privacy: 'secret', viewable_by_parent_members: true, parent: private_group }

    subject { groups_displayed(user: user,
                               group: private_group) }
    before do
      private_group
      public_subgroup
      private_subgroup
      secret_subgroup
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

      context 'and secret subgroup' do
        before { secret_subgroup.add_member!(user)}

        it { should include private_group,
                            public_subgroup,
                            private_subgroup,
                            secret_subgroup }

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

      context 'not member of secret subgroup, but it is viewable by parent group members' do
        before { secret_vbpm_subgroup }
        it { should include private_group,
                            public_subgroup,
                            private_subgroup,
                            secret_vbpm_subgroup }

        its(:size) { should == 4 }
      end
    end
  end

  describe 'when viewing secret group' do
    let(:secret_group) { create :group, privacy: 'secret' }
    let(:secret_subgroup) { create :group, parent: secret_group, privacy: 'secret' }
    let(:secret_vbpm_subgroup) { create :group, privacy: 'secret', viewable_by_parent_members: true, parent: secret_group }

    subject { groups_displayed(user: user,
                               group: secret_group) }

    context 'as guest' do
      its(:size){ should == 0 }
    end

    context 'as member of group' do
      before { secret_group.add_member!(user) }

      context 'only' do
        it { should == [secret_group] }
      end

      context 'and secret subgroup' do
        before { secret_subgroup.add_member!(user) }

        it { should include secret_group,
                            secret_subgroup }

        its(:size) { should == 2 }
      end

      context 'not member of secret subgroup, but it is viewable by parent group members' do
        before { secret_vbpm_subgroup }
        it { should include secret_group,
                            secret_vbpm_subgroup }

        its(:size) { should == 2 }
      end
    end
  end
end
