require 'spec_helper'

describe Queries::VisibleDiscussions do
  let(:user) { create :user }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }

  subject do
    Queries::VisibleDiscussions.new(user: user, groups: [group])
  end

  describe 'viewable_by' do
    context 'everyone (aka public)' do
      before { group.update_attribute(:viewable_by, 'everyone') }

      it 'guests can see discussions' do
        subject.should include discussion
      end

      it 'members can see discussions' do
        group.add_member! user
        subject.should include discussion
      end
    end

    context 'members' do
      before { group.update_attribute(:viewable_by, 'members') }

      it 'guests cannot see discussions' do
        subject.should_not include discussion
      end

      it 'members can see discussions' do
        group.add_member! user
        subject.should include discussion
      end
    end

    context 'parent_group_members' do
      let(:parent_group) { create :group }
      let(:group) { create :group, parent: parent_group }

      before { group.update_attribute(:viewable_by, 'parent_group_members') }

      it 'guests cannot see discussions' do
        subject.should_not include discussion
      end

      it 'member of parent group can see discussions' do
        parent_group.add_member! user
        subject.should include discussion
      end

      it 'members can see discussions' do
        parent_group.add_member! user
        group.add_member! user
        subject.should include discussion
      end
    end
  end

  describe 'archived' do
    it 'does not return discussions in archived groups' do
      discussion
      group.archive!
      subject.should_not include discussion
    end
  end

  # test that archived group not viewable

  #describe "#with_open_motions" do
    #before do
      #@discussion_with_motion_in_public_group = create :discussion, group: public_group
      #@motion = create :current_motion, discussion: @discussion_with_motion_in_public_group
    #end

    #subject do
      #Queries::VisibleDiscussions.new(user: non_member, groups: [public_group]).with_open_motions
    #end

    #it {should include @discussion_with_motion_in_public_group}
    #its(:size){should == 1}
  #end

  #describe "#without_open_motions" do
    #before do
      #@discussion_with_motion_in_public_group = create :discussion, group: public_group
      #@motion = create :current_motion, discussion: @discussion_with_motion_in_public_group
    #end

    #subject do
      #Queries::VisibleDiscussions.new(groups: [public_group]).without_open_motions
    #end

    #it {should_not include @discussion_with_motion_in_public_group}
  #end
end
