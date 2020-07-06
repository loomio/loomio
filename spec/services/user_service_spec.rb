require 'rails_helper'
describe UserService do

  describe 'deactivate' do
    before do
      @user = FactoryBot.create :user
      @group = FactoryBot.create :group
      @membership = @group.add_member! @user
      @discussion = FactoryBot.create :discussion, author: @user, group: @group
    end

    it "deactivates the user" do
      zombie = UserService.deactivate(user: @user)
      expect(@membership.reload.archived_at).to be_present
    end

    it "changes their email address" do
      UserService.deactivate(user: @user)
      @user.reload
      expect(@user.email).to match /deactivated-user-.+@example.com/
    end
  end

  describe 'verify' do
    it 'sets email_verified true if email is unique' do
      user = FactoryBot.create(:user, email_verified: false, email: 'user@example.com')
      user = UserService.verify(user: user)
      expect(user.email_verified).to be true
    end

    it 'returns user if already verified' do
      user = FactoryBot.create(:user, email_verified: true, email: 'user@example.com')
      user = UserService.verify(user: user)
      expect(user.email_verified).to be true
    end
  end

  describe 'delete_spam' do
    let(:spam_user) { FactoryBot.create :user }
    let(:spam_group) { FactoryBot.build :group }
    let(:innocent_group) { FactoryBot.create :group }
    let(:discussion_in_spam_group) { FactoryBot.build :discussion, group: spam_group }
    let(:spam_discussion_in_innocent_group) { FactoryBot.build :discussion, group: innocent_group }
    let(:discussion_in_innocent_group) { FactoryBot.create :discussion, group: innocent_group }
    let(:spam_comment) { FactoryBot.build :comment, discussion: discussion_in_innocent_group }

    before do
      #the create the spam group
      GroupService.create(group: spam_group, actor: spam_user)

      #they create a spam discussion in the spam group
      DiscussionService.create(discussion: discussion_in_spam_group, actor: spam_user)

      # they join an innocent group such as loomio commune
      innocent_group.add_member! spam_user

      # spam the loomio commune group with a discussion
      DiscussionService.create(discussion: spam_discussion_in_innocent_group, actor: spam_user.reload)

      # spam the loomio communie discussion with comments
      CommentService.create(comment: spam_comment, actor: spam_user)

      UserService.destroy(user: spam_user)
    end

    it 'destroys the groups created by the user' do
      expect(Group.exists?(spam_group.id)).to be false
      expect(Group.exists?(innocent_group.id)).to be true
    end

    it 'destroys the user' do
      expect { spam_user.reload }.to raise_error ActiveRecord::RecordNotFound
    end

    it 'destroys the discussions in the spammy groups' do
      expect(Discussion.exists?(discussion_in_spam_group.id)).to be false
    end

    it 'destroys spammy discussions in innocent groups' do
      expect(Discussion.exists?(spam_discussion_in_innocent_group.id)).to be false
    end

    it 'destroys spammy comments in innocent groups' do
      expect(Comment.exists?(spam_comment.id)).to be false
    end
  end
end
