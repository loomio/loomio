require 'spec_helper'

describe Events::NewComment do
  let(:comment){ mock_model(Comment, discussion: mock_model(Discussion))}

  describe "::publish!" do
    let(:event) { stub(:event, notify_users!: true) }
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
  end

  context "after event has been published" do
    let(:mentioned_user) { mock_model(User) }
    let(:non_mentioned_user) { mock_model(User) }
    let(:event) { Events::NewComment.new(kind: "new_comment",
                                         eventable: comment,
                                         discussion_id: comment.discussion.id) }
    before do
      comment.stub(:mentioned_group_members).and_return([mentioned_user])
      comment.stub(:non_mentioned_discussion_participants).and_return([non_mentioned_user])
      Events::UserMentioned.stub(:publish!)
    end

    it 'fires a user_mentioned! event for each mentioned group member' do
      Events::UserMentioned.should_receive(:publish!).with(comment, mentioned_user)
      event.save
    end

    it 'calls event.notify! for each non mentioned group member' do
      event.should_receive(:notify!).with(non_mentioned_user)
      event.save
    end
  end
end