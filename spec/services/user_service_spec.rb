require 'rails_helper'
describe UserService do
  describe 'verify' do
    it 'sets email_verfied true if email is unique' do
      user = FactoryGirl.create(:user, email_verified: false, email: 'user@example.com')
      user = UserService.verify(user: user)
      expect(user.email_verified).to be true
    end

    it 'merges unverified user records into verified user if verified email exists' do
      verified_user = FactoryGirl.create(:user, email_verified: true, email: 'user@example.com')
      unverified_user = FactoryGirl.create(:user, email_verified: false, email: 'user@example.com')
      stance = FactoryGirl.create(:stance, participant: unverified_user)
      user = UserService.verify(user: unverified_user)
      expect(user).to eq verified_user
      expect(user.email_verified).to be true
      expect(user.stances.first).to eq stance
      expect(unverified_user.stances).to be_empty
    end

    it 'returns user if already verified' do
      user = FactoryGirl.create(:user, email_verified: true, email: 'user@example.com')
      user = UserService.verify(user: user)
      expect(user.email_verified).to be true
    end

    it 'verified vote exists, vote as unverified user then verify' do
      poll = FactoryGirl.create(:poll)

      verified_user = FactoryGirl.create(:user, email_verified: true, email: 'user@example.com')
      verified_stance = FactoryGirl.create(:stance, poll: poll, participant: verified_user)

      unverified_user = FactoryGirl.create(:user, email_verified: false, email: 'user@example.com')
      unverified_stance = FactoryGirl.create(:stance, poll: poll, participant: unverified_user)

      UserService.verify(user: unverified_user)

      # both votes are recorded, and most recent, is set latest
      expect(poll.stances.count).to eq 2
      expect(unverified_stance.reload.latest).to be true
      expect(verified_stance.reload.latest).to be false
      expect(verified_user.stances).to include unverified_stance, verified_stance
      expect(verified_user.stances.count).to eq 2
    end
  end

  describe 'delete_spam' do
    let(:spam_user) { FactoryGirl.create :user }
    let(:spam_group) { FactoryGirl.build :group }
    let(:innocent_group) { FactoryGirl.create :formal_group }
    let(:discussion_in_spam_group) { FactoryGirl.build :discussion, group: spam_group }
    let(:spam_discussion_in_innocent_group) { FactoryGirl.build :discussion, group: innocent_group }
    let(:discussion_in_innocent_group) { FactoryGirl.create :discussion, group: innocent_group }
    let(:spam_comment) { FactoryGirl.build :comment, discussion: discussion_in_innocent_group }

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

      UserService.delete_spam(spam_user)
    end

    it 'destroys the groups created by the user' do
      expect(Group.exists?(spam_group.id)).to be false
      expect(Group.exists?(innocent_group.id)).to be true
    end

    it 'destroys the user' do
      spam_user.persisted?.should be false
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
