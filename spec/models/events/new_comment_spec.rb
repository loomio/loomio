require 'rails_helper'

describe Events::NewComment do
  let(:discussion) { create :discussion }
  let(:parent_user) { create :user, email: 'dave@bill.com' }
  let(:user) { create :user, email: 'bill@dave.com' }

  let(:parent) { create :comment, discussion: discussion, author: parent_user }
  let(:comment) { create :comment, discussion: discussion, parent: parent, author: user }

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
      Events::NewComment.publish!(comment).should == event
    end

    it 'publishes a comment replied to event if there is a comment' do
      Events::CommentRepliedTo.should_receive(:publish!).with(parent)
      Events::NewComment.publish! comment
    end
  end
end
