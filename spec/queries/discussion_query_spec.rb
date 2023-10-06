require 'rails_helper'

describe DiscussionQuery do
  let(:user) { create :user }
  let(:group) { create :group, discussion_privacy_options: 'public_or_private' }
  let(:author) { create :user }
  let(:discussion) { create :discussion, group: group, author: author, private: true }

  subject do
    DiscussionQuery.visible_to(user: user, group_ids: [group.id])
  end

  describe 'logged out' do
    let!(:public_discussion) { create(:discussion, private: false, group: create(:group, is_visible_to_public: true)) }
    let!(:another_public_discussion) { create(:discussion, private: false, group: create(:group, is_visible_to_public: true)) }
    let!(:private_discussion) { create(:discussion, group: create(:group, is_visible_to_public: false)) }

    it 'shows groups visible to public if no groups are specified' do
      query = DiscussionQuery.visible_to
      expect(query).to include public_discussion
      expect(query).to include another_public_discussion
      expect(query).to_not include private_discussion
    end

    it 'shows specified groups if they are public' do
      query = DiscussionQuery.visible_to(group_ids: [public_discussion.group_id])
      expect(query).to include public_discussion
      expect(query).to_not include another_public_discussion
      expect(query).to_not include private_discussion
    end

    it 'shows nothing if no public groups are specified' do
      query = DiscussionQuery.visible_to(group_ids: [private_discussion.group_id])
      expect(query).to_not include public_discussion
      expect(query).to_not include another_public_discussion
      expect(query).to_not include private_discussion
    end
  end

  describe 'unread' do
    before do
      group.add_member! author
      group.add_member! user
      #group.add_member! uses
      #comment = FactoryBot.build(:comment, discussion: discussion, author: discussion.author)
      #CommentService.create(comment: comment, actor: discussion.author)
    end

    it 'unread discussions with no comments' do
      DiscussionQuery.visible_to(user: user, only_unread: true).should include discussion
    end

    it 'does not include dismissed discussions' do
      DiscussionReader.for(discussion: discussion, user: user).dismiss!
      DiscussionQuery.visible_to(user: user, only_unread: true).should_not include discussion
    end
  end

  describe 'privacy' do
    let(:discussion_user) { create :user }
    let(:group_user) { create :user }
    let(:parent_group_user) { create :user }
    let(:public_user) { create :user }
    let(:parent_group) { create :group, discussion_privacy_options: 'public_or_private' }

    before do
      group.update(parent: parent_group)
      discussion.add_guest!(discussion_user, discussion.author)
      group.add_member!(group_user)
      parent_group.add_member!(parent_group_user)
    end

    it "nullgroup" do
      discussion.update(group_id: nil)
      expect(DiscussionQuery.visible_to(user: discussion_user).exists?(discussion.id)).to be true
      expect(DiscussionQuery.visible_to(user: group_user).exists?(discussion.id)).to be false
      expect(DiscussionQuery.visible_to(user: public_user, or_public: true).exists?(discussion.id)).to be false
      expect(discussion.members.exists?(discussion_user.id)).to be true
      expect(discussion.members.exists?(group_user.id)).to be false
      expect(discussion.members.exists?(public_user.id)).to be false
    end

    it "group" do
      expect(DiscussionQuery.visible_to(user: discussion_user).exists?(discussion.id)).to be true
      expect(DiscussionQuery.visible_to(user: group_user).exists?(discussion.id)).to be true
      expect(DiscussionQuery.visible_to(user: public_user, or_public: true).exists?(discussion.id)).to be false
      expect(discussion.members.exists?(discussion_user.id)).to be true
      expect(discussion.members.exists?(group_user.id)).to be true
      expect(discussion.members.exists?(public_user.id)).to be false
    end

    it "public" do
      discussion.update(private: false)
      expect(DiscussionQuery.visible_to(user: discussion_user).exists?(discussion.id)).to be true
      expect(DiscussionQuery.visible_to(user: group_user).exists?(discussion.id)).to be true
      expect(DiscussionQuery.visible_to(user: public_user, or_public: true).exists?(discussion.id)).to be true
      expect(discussion.members.exists?(discussion_user.id)).to be true
      expect(discussion.members.exists?(group_user.id)).to be true
      # expect(discussion.members.exists?(public_user.id)).to be true
    end
  end

  # describe 'group.discussion_visible_to_options' do
  #   context 'public' do
  #     before do
  #       # group.update(discussion_visible_to_options: ['public', 'group', 'members'])
  #       discussion.update_attribute(:visible_to, 'public')
  #     end
  #
  #     it 'guests can see discussions' do
  #       subject.should include discussion
  #     end
  #
  #     it 'members can see discussions' do
  #       group.add_member! user
  #       subject.should include discussion
  #     end
  #   end
  #
  #
  #   context 'group' do
  #     before do
  #       # group.update(discussion_visible_to_options: ['public', 'group', 'members'])
  #       discussion.update_attribute(:private, true)
  #     end
  #
  #     it 'guests cannot see discussions' do
  #       subject.should_not include discussion
  #     end
  #
  #     it 'members can see discussions' do
  #       group.add_member! user
  #       subject.should include discussion
  #     end
  #   end
  #
  context 'parent_members_can_see_discussions' do
    let(:parent_group) { create :group, group_privacy: 'secret'}
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

  context 'only members can see discussions' do
    let(:parent_group) { create :group }
    let(:group) { create :group,
                         parent: parent_group,
                         parent_members_can_see_discussions: false,
                         is_visible_to_parent_members: true }

    it 'prevents parent group members from seeing discussions' do
      subject.should_not include discussion
    end
  end

  describe 'archived' do
    it 'does not return discussions in archived groups' do
      discussion
      group.archive!
      subject.should_not include discussion
    end
  end

  describe 'guest access' do
    let(:discussion) { create :discussion, author: author, private: true }
    it 'returns discussions via discussion reader' do
      discussion.add_guest!(user, discussion.author)
      DiscussionQuery.visible_to(user: user).should include discussion
    end

    it 'returns discussions via discussion reader' do
      discussion
      DiscussionQuery.visible_to(user: user).should_not include discussion
    end
  end

  describe 'tags' do
    let!(:tag) { create :tag, group_id: group.id, name: 'test', color: '#abc' }
    let!(:tagged_discussion) { create :discussion, author: author, private: true, group: group, tags: ["test"] }
    let!(:untagged_discussion) { create :discussion, author: author, private: true, group: group, tags: [] }
    let!(:group) { create :group }

    before do
      group.add_member! user
    end

    it 'returns tagged discussions' do
      DiscussionQuery.visible_to(user: user, tags: ['test']).should include tagged_discussion
      DiscussionQuery.visible_to(user: user, tags: ['test']).should_not include untagged_discussion
    end
  end
end
