require 'rails_helper'

describe GroupDiscussionsViewer do

  let(:user) { create :user }

  def groups_displayed(user: , group: )
    GroupDiscussionsViewer.groups_displayed(user: user, group: group)
  end

  describe 'viewing visible group' do
    let(:visible_group) { create :group, is_visible_to_public: true, name: 'public group' }
    let(:visible_subgroup) { create :group, parent: visible_group, is_visible_to_public: true, name: 'public subgroup' }
    let(:hidden_subgroup) { create :group, parent: visible_group, is_visible_to_public: false, name: 'hidden subgroup' }

    subject { groups_displayed(user: user, group: visible_group) }

    before do
      visible_group
      visible_subgroup
      hidden_subgroup
    end

    context 'as guest' do
      it { should include visible_group,
                          visible_subgroup }

      its(:size){should == 2}
    end

    context 'as member of parent group' do
      before { visible_group.add_member!(user) }

      context 'only' do
        it { should include visible_group,
                            visible_subgroup }

        its(:size){should == 2}
      end

      context 'and hidden subgroup' do
        before { hidden_subgroup.add_member!(user) }

        it {should include visible_group,
                           visible_subgroup,
                           hidden_subgroup }

        its(:size){should == 3}
      end
    end
  end

  describe 'when viewing hidden group' do
    let(:hidden_group) { create :group, is_visible_to_public: false }
    let(:hidden_subgroup) { create :group, parent: hidden_group, is_visible_to_public: false }
    let(:visible_subgroup) { create :group, is_visible_to_public: true, parent: hidden_group }

    subject { groups_displayed(user: user,
                               group: hidden_group) }

    context 'as guest' do
      its(:size){ should == 0 }
    end

    context 'as member of parent group' do
      before do
        hidden_group.add_member!(user)
        hidden_subgroup
        visible_subgroup
      end

      context 'only' do
        it { should include hidden_group,
                            visible_subgroup }

        its(:size) { should == 2 }
      end

      context 'and hidden subgroup' do
        before { hidden_subgroup.add_member!(user) }

        it { should include hidden_group,
                            hidden_subgroup,
                            visible_subgroup }

        its(:size) { should == 3 }
      end
    end
  end
end
