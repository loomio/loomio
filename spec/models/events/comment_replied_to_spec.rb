require 'rails_helper'

describe Events::CommentRepliedTo do
  let(:discussion) { create :discussion }
  let!(:comment) { create(:comment, discussion: discussion, parent: parent) }
  let!(:parent) { create(:comment, discussion: discussion) }
  let(:event) { double(notify!: true) }

  describe "::publish!" do

    it 'creates an event' do
      expect(Event).to receive(:create!).with(kind: 'comment_replied_to',
                                              eventable: comment,
                                              created_at: comment.created_at).and_return(event)
      expect(ThreadMailer).to receive(:delay).and_return(double(comment_replied_to: true))
      Events::CommentRepliedTo.publish!(comment)
    end

    it 'returns an event' do
      expect(Events::CommentRepliedTo.publish!(comment)).to be_a Event
    end

    it 'emails the parent author' do
      expect(Event).to receive(:create!).with(kind: 'comment_replied_to',
                                              eventable: comment,
                                              created_at: comment.created_at).and_return(event)
      expect(ThreadMailer).to receive(:delay).and_return(double(comment_replied_to: true))
      expect(event).to receive(:notify!)
      Events::CommentRepliedTo.publish!(comment)
    end

    it 'does not email when the comment and reply author are the same' do
      parent.update author: comment.author
      expect(Event).to receive(:create!).with(kind: 'comment_replied_to',
                                              eventable: comment,
                                              created_at: comment.created_at).and_return(event)
      expect(ThreadMailer).to_not receive(:delay)
      expect(event).to_not receive(:notify!)
      Events::CommentRepliedTo.publish!(comment)
    end
  end
end
