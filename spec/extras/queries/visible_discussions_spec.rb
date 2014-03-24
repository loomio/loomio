require 'spec_helper'

describe Queries::VisibleDiscussions do
  let(:user) { create :user }
  let(:group) { create :group, private_discussions_only: false }
  let(:discussion) { create_discussion group: group, private: true }

  subject do
    Queries::VisibleDiscussions.new(user: user, groups: [group])
  end

  describe 'discussion privacy' do
    context 'private' do
      before { discussion.update_attribute(:private, true) }

      it 'guests cannot see discussion' do
        subject.should_not include discussion
      end

      it 'members can see discussion' do
        group.add_member! user
        subject.should include discussion
      end
    end

    context 'not private' do
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
    context 'public discussions allowed' do
      before do
        group.update_attribute(:private_discussions_only, false)
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

    context 'private discussions only' do
      before do
        group.update_attribute(:private_discussions_only, true)
        discussion.update_attribute(:private, true)
      end

      it 'guests cannot see discussions' do
        subject.should_not include discussion
      end

      it 'members can see discussions' do
        group.add_member! user
        subject.should include discussion
      end
    end

    context 'viewable by parent group members' do
      let(:parent_group) { create :group, private_discussions_only: true }
      let(:group) { create :group,
                           parent: parent_group,
                           visible_to_parent_members: true,
                           private_discussions_only: true }

      before do
        discussion.update_attribute(:private, true)
      end

      it 'non members cannot see discussions' do
        subject.should_not include discussion
      end

      it 'member of parent group can see discussions' do
        parent_group.add_member! user
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
end
