require 'rails_helper'

describe Queries::VisibleDiscussions do
  let(:user) { create :user }
  let(:group) { create :group, discussion_privacy_options: 'public_or_private' }
  let(:author) { create :user }
  let(:discussion) { create :discussion, group: group, author: author, private: true }

  subject do
    Queries::VisibleDiscussions.new(user: user, groups: [group])
  end

  describe 'unread', focus: true do
    before do
      group.add_member! author
      group.add_member! user
      #group.add_member! uses
      #comment = FactoryGirl.build(:comment, discussion: discussion, author: discussion.author)
      #CommentService.create(comment: comment, actor: discussion.author)
    end

    it 'unread discussions with no comments' do
      #user.discussions.should include discussion
      subject.unread.should include discussion
    end

    it 'shows unread discussions with comments'
    it 'shows unread discussions with some read comments'
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
        group.update_attribute(:discussion_privacy_options, 'public_or_private')
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
        group.update_attribute(:discussion_privacy_options, 'private_only')
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

    context 'parent_members_can_see_discussions' do
      let(:parent_group) { create :group, is_visible_to_public: false, discussion_privacy_options: 'private_only' }
      let(:group) { create :group,
                           parent: parent_group,
                           parent_members_can_see_discussions: true,
                           is_visible_to_public: false,
                           is_visible_to_parent_members: true,
                           discussion_privacy_options: 'private_only' }

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
