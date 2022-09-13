require 'rails_helper'

describe DiscussionReaderService do
  let(:group) { create :group }
  let(:discussion) { create :discussion, group: group }
  let(:guest_discussion_reader) { create :discussion_reader, discussion: discussion, user: guest, inviter: discussion.author }
  let(:member_discussion_reader) { create :discussion_reader, discussion: discussion, user: member, inviter: discussion.author }
  let(:user) { create :user }
  let(:member) { create :user }
  let(:guest) { create :user, email_verified: false}

  before do
    discussion.created_event
    group.add_member! user
    group.add_member! member
  end

  describe 'redeem' do
    it 'redeems a guest discussion_reader' do
      expect(guest.email_verified).to be false
      expect(user.email_verified).to be true
      expect(guest_discussion_reader.reload.user).to eq guest
      DiscussionReaderService.redeem(discussion_reader: guest_discussion_reader, actor: user)
      expect(guest_discussion_reader.reload.user).to eq user
    end

    it 'does not redeem reader for another verified user' do
      expect(member_discussion_reader.reload.user).to eq member
      DiscussionReaderService.redeem(discussion_reader: member_discussion_reader, actor: user)
      expect(member_discussion_reader.reload.user).to eq member
    end
  end
end
