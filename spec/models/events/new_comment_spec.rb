require 'rails_helper'

describe Events::NewComment do
  let(:comment){ mock_model(Comment, discussion: mock_model(Discussion))}

  describe "::publish!" do
    let(:event) { double(:event, notify_users!: true) }
    before { Event.stub(:create!).and_return(event) }

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'new_comment',
                                          eventable: comment,
                                          discussion_id: comment.discussion.id)
      Events::NewComment.publish!(comment)
    end

    it 'returns an event' do
      Events::NewComment.publish!(comment).should == event
    end

    it 'enfollows the author'
    it 'creates mention events'
    it 'emails discussion followers but not comment author or mentioned users'
  end
end
