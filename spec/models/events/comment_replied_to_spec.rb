require 'rails_helper'

describe Events::CommentRepliedTo do
  let(:discussion) { create :discussion }
  let!(:comment) { create(:comment, discussion: discussion, parent: parent) }
  let!(:parent) { create(:comment, discussion: discussion) }

  describe "::publish!" do

    it 'returns an event' do
      expect(Events::CommentRepliedTo.publish!(comment)).to be_a(Event)
    end

    it 'creates a comment replied to event' do
      expect { Events::CommentRepliedTo.publish!(comment) }.to change { Event.where(kind: 'comment_replied_to').count }.by(1)
    end

    it 'emails the parent author' do
      expect { Events::CommentRepliedTo.publish!(comment) }.to change { ActionMailer::Base.deliveries.count }.by(1)
    end

    it 'creates a notification' do
      expect { Events::CommentRepliedTo.publish!(comment) }.to change { Notification.count }.by(1)
    end

    it 'does not email when the comment and reply author are the same' do
      parent.update author: comment.author
      expect(Event).to_not receive(:create!)
      expect(ThreadMailer).to_not receive(:delay)
      expect { Events::CommentRepliedTo.publish!(comment) }.to_not change { Notification.count }
    end
  end
end
