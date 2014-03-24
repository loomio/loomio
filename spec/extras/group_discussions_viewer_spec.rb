require 'spec_helper'

describe GroupDiscussionsViewer do

  let(:user) { create :user }

  def groups_displayed(user: user, group: group)
    GroupDiscussionsViewer.groups_displayed(user: user, group: group)
  end

  describe 'viewing visible group' do
    let(:public_group) { create :group, visible: true, name: 'public group' }
    let(:public_subgroup) { create :group, parent: public_group, visible: true, name: 'public subgroup' }
    let(:hidden_subgroup) { create :group, parent: public_group, visible: false, name: 'hidden subgroup' }
    let(:vbpm_subgroup) { create :group, visible: false, visible_to_parent_members: true, parent: public_group, name: 'hidden vbpm subgroup' }

    subject { groups_displayed(user: user, group: public_group) }

    before do
      public_group
      public_subgroup
      hidden_subgroup
      vbpm_subgroup
    end

    context 'as guest' do
      it { should include public_group,
                          public_subgroup }

      its(:size){should == 2}
    end

    context 'as member of parent group' do
      before { public_group.add_member!(user) }

      context 'only' do
        it { should include public_group,
                            public_subgroup,
                            vbpm_subgroup }

        its(:size){should == 3}
      end

      context 'and hidden subgroup' do
        before { hidden_subgroup.add_member!(user) }

        it {should include public_group,
                           public_subgroup,
                           hidden_subgroup,
                           vbpm_subgroup }

        its(:size){should == 4}
      end
    end
  end

  describe 'when viewing hidden group' do
    let(:hidden_group) { create :group, visible: false }
    let(:hidden_subgroup) { create :group, parent: hidden_group, visible: false }
    let(:vbpm_subgroup) { create :group, visible: false, visible_to_parent_members: true, parent: hidden_group }

    subject { groups_displayed(user: user,
                               group: hidden_group) }

    context 'as guest' do
      its(:size){ should == 0 }
    end

    context 'as member of group' do
      before do
        hidden_group.add_member!(user)
        vbpm_subgroup
      end

      context 'only' do
        it { should include hidden_group,
                            vbpm_subgroup }

        its(:size) { should == 2 }
      end

      context 'and hidden subgroup' do
        before { hidden_subgroup.add_member!(user) }

        it { should include hidden_group,
                            hidden_subgroup,
                            vbpm_subgroup }

        its(:size) { should == 3 }
      end
    end
  end
end
