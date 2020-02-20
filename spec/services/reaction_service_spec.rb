require 'rails_helper'

describe ReactionService do
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:reaction) { build :reaction, reaction: ":heart:", reactable: comment, user: user }
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:comment) { create :comment, discussion: discussion, author: user }

  before do
    group.add_member! user
    group.add_member! another_user
  end

  describe 'update' do
    it 'creates a like for the current user on a comment' do
      expect { ReactionService.update(reaction: reaction, params: {reaction: 'smiley'}, actor: user) }.to change { Reaction.count }.by(1)
    end

    it 'does not notify if the user is no longer in the group' do
      comment
      group.memberships.find_by(user: reaction.author).destroy
      expect { ReactionService.update(reaction: reaction, params: {reaction: 'smiley'}, actor: another_user) }.to_not change { user.notifications.count }
    end
  end

  describe 'destroy' do
    before { reaction.save }

    it 'removes a like for the current user on a comment' do
      expect { ReactionService.destroy(reaction: reaction, actor: user) }.to change { Reaction.count }.by(-1)
    end

    it 'does not allow others to destroy a reaction' do
      expect { ReactionService.destroy(reaction: reaction, actor: another_user) }.to raise_error { CanCan::AccessDenied }
    end
  end
end
