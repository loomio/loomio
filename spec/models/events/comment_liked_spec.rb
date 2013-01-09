require 'spec_helper'

describe Events::CommentLiked do
  describe "::publish!" do
    let(:event) { stub(:event, :notify_users! => true) }
    let(:comment_like) { mock_model(CommentVote) }
    before { Event.stub(:create!).and_return(event) }

    it 'creates an event' do
      Event.should_receive(:create!).with(kind: 'comment_liked',
                                          eventable: comment_like)
      Events::CommentLiked.publish!(comment_like)
    end

    it 'returns an event' do
      Events::CommentLiked.publish!(comment_like).should == event
    end
  end

  context "after event has been published" do
    let(:commenter) { stub(:commenter) }
    let(:voter) { stub(:voter) }
    let(:comment_like) { mock_model(CommentVote, comment_user: commenter,
                                    user: voter) }
    let(:event) { Events::CommentLiked.new(kind: "new_comment",
                                           eventable: comment_like) }

    it 'notifies the comment author' do
      event.should_receive(:notify!).with(commenter)
      event.save
    end

    it 'does not notify the user if they like their own comment' do
      comment_like.stub(:user).and_return(commenter)
      event.should_not_receive(:notify!)
      event.save
    end
  end
end