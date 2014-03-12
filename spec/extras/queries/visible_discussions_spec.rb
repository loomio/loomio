require 'spec_helper'

describe Queries::VisibleDiscussions do
  let(:user) { create :user }
  let(:group) { create :group }
  let(:discussion) { create_discussion group: group }

  subject do
    Queries::VisibleDiscussions.new(user: user, groups: [group])
  end

  describe 'when discussion.private?' do
    context 'true (private)' do
      before { discussion.update_attribute(:private, true) }

      it 'guests cannot see discussion' do
        subject.should_not include discussion
      end

      it 'members can see discussion' do
        group.add_member! user
        subject.should include discussion
      end
    end

    context 'false (public)' do
      before { discussion.update_attribute(:private, false) }
      it 'guests can see discussion' do
        subject.should include discussion
      end

      it 'members can see discussion' do
        group.add_member! user
        subject.should include discussion
      end
    end

  end

  describe 'group privacy' do
    context 'public (aka public)' do
      before do
        group.update_attribute(:privacy, 'public')
        discussion.update_attribute(:private, false)
      end

      it 'guests can see discussions' do
        subject.should include discussion
      end

      it 'members can see discussions' do
        group.add_member! user
        subject.should include discussion
      end
    end

    context 'hidden' do
      before { group.update_attribute(:privacy, 'hidden') }

      it 'guests cannot see discussions' do
        subject.should_not include discussion
      end

      it 'members can see discussions' do
        group.add_member! user
        subject.should include discussion
      end
    end

    context 'viewable by parent group members' do
      let(:parent_group) { create :group }
      let(:group) { create :group,
                           parent: parent_group,
                           viewable_by_parent_members: true,
                           privacy: 'hidden' }

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
