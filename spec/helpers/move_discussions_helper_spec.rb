require 'spec_helper'

describe MoveDiscussionsHelper do
  let(:user) { FactoryGirl.create :user }
  let(:parent_group) { FactoryGirl.create :group, name: 'parent' }
  let(:sub_group) { FactoryGirl.create :group, name: 'child', parent: parent_group }

  before do
    parent_group.add_member! user
    sub_group
    parent_group.reload
  end

  subject do
    helper.destinations_for(discussion: discussion, user: user)
  end

  context "#destinations_for" do
    before do
      unrelated_group = FactoryGirl.create :group
      unrelated_group.add_admin! user
    end

    context "user is admin of sub_group" do
      before { sub_group.add_admin!(user) }

      context "discussion is in parent group" do
        let(:discussion) { create_discussion(group: parent_group)  }
        it {should be_empty}
      end

      context "discussion is in sub_group" do
        let(:discussion) { create_discussion(group: sub_group)  }
        it {should be_empty}
      end
    end

    context "user is admin of parent_group" do
      before { parent_group.add_admin!(user) }

      context "discussion is in parent group" do
        let(:discussion) { create_discussion(group: parent_group)  }
        it {should be_empty}
      end

      context "discussion is in sub_group" do
        let(:discussion) { create_discussion(group: sub_group)  }
        it {should be_empty}

      end
    end

    context "user is admin of subgroup and parent group" do
      before do
        parent_group.add_admin!(user)
        sub_group.add_admin!(user)
      end

      context "discussion is in parent group", focus: true do
        let(:discussion) { create_discussion(group: parent_group)  }
        it {should include sub_group}
        its(:size) {should == 1}
      end

      context "discussion is in subgroup" do
        let(:discussion) { create_discussion(group: sub_group)  }
        it {should include parent_group}
        its(:size) {should == 1}
      end
    end
  end
end
