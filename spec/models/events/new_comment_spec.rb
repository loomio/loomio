require 'rails_helper'

describe Events::NewComment do
  let(:discussion) { create :discussion }
  let(:user) { create :user, email: 'bill@dave.com' }
  let(:comment) { create :comment, discussion: discussion, author: user }

  describe "::publish!" do
    let(:event) { double(:event, notify_users!: true) }
    before { Event.stub(:create!).and_return(event) }

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'new_comment',
                                          eventable: comment,
                                          discussion: comment.discussion,
                                          created_at: comment.created_at)
      Events::NewComment.publish!(comment)
    end

    it 'returns an event' do
      expect(Events::NewComment.publish!(comment)).to eq event
    end

    it 'does not publish a comment replied to event if there is no parent' do
      Events::CommentRepliedTo.should_not_receive(:publish!).with(comment)
      Events::NewComment.publish! comment
    end

    it 'publishes a comment replied to event if there is a comment' do
      comment.parent = create :comment
      Events::CommentRepliedTo.should_receive(:publish!).with(comment)
      Events::NewComment.publish! comment
    end
  end
end
