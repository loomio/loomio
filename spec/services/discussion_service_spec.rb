require_relative '../../app/services/discussion_service'

module Events
  class NewComment
  end
  class CommentLiked
  end
end

class Motion
end

describe 'DiscussionService' do
  let(:motion) { double(:motion) }
  let(:comment_vote) { double(:comment_vote) }
  let(:ability) { double(:ability, :authorize! => true) }
  let(:user) { double(:user, ability: ability) }
  let(:comment) { double(:comment,
                         save: true,
                         'author=' => nil,
                         created_at: :a_time,
                         discussion: discussion,
                         author: user) }


  let(:discussion) { double(:discussion, update_attribute: true) }
  let(:event) { double(:event) }

  describe 'new_proposal' do
    before do
      motion.stub(:discussion=).and_return(discussion)
      Motion.stub(:new).and_return(motion)
    end

    context 'motion does not exist for discussion' do
      before do
        discussion.stub_chain(:current_motion).and_return(nil)
      end

      it 'initializes a new motion' do
        Motion.should_receive(:new)
        DiscussionService.new_proposal(discussion)
      end

      it 'sets the motions discuusion' do
        motion.should_receive(:discussion=).with(discussion)
        DiscussionService.new_proposal(discussion)
      end

      it 'returns the new motion' do
        DiscussionService.new_proposal(discussion).should == motion
      end
    end

    context 'motion does not exist for discussion' do
      before do
        discussion.stub(:current_motion).and_return(motion)
      end

      it 'returns nil' do
        DiscussionService.new_proposal(discussion).should == nil
      end
    end
  end

  describe 'unlike_comment' do
    after do
      DiscussionService.unlike_comment(user, comment)
    end

    it 'calls unlike on the comment' do
      comment.should_receive(:unlike).with(user)
    end
  end

  describe 'like_comment' do
    before do
      Events::CommentLiked.stub(:publish!)
      ability.stub(:can?)
      comment.stub(:like).and_return(comment_vote)
    end

    after do
      DiscussionService.like_comment(user, comment)
    end

    it 'checks the user can like the comment' do
      ability.should_receive(:can?).with(:like_comments, discussion)
    end

    it 'creates a comment vote' do
      comment.should_receive(:like).with(user).and_return(comment_vote)
    end

    it 'publishes a like comment event' do
      Events::CommentLiked.should_receive(:publish!).with(comment_vote)
    end
  end

  describe 'add_comment' do
    before do
      Events::NewComment.stub(:publish!).and_return(event)
    end

    after do
      DiscussionService.add_comment(comment)
    end

    it 'authorizes that the user can add the comment' do
      ability.should_receive(:authorize!).with(:add_comment, discussion)
    end

    it 'saves the comment' do
      comment.should_receive(:save).and_return(true)
    end

    context 'comment is valid' do
      before do
        comment.stub(:save).and_return(true)
      end

      it 'fires a NewComment event' do
        Events::NewComment.should_receive(:publish!).with(comment)
      end

      it 'updates discussion last_comment_at' do
        discussion.should_receive(:update_attribute).with(:last_comment_at, comment.created_at)
      end

      it 'returns the event created' do
        DiscussionService.add_comment(comment).should == event
      end
    end

    context 'comment is invalid' do
      before do
        comment.stub(:save).and_return(false)
      end

      it 'returns false' do
        DiscussionService.add_comment(comment).should == false
      end

      it 'does not create new comment event' do
        Events::NewComment.should_not_receive(:publish!)
      end

      it 'does not update discussion' do
        discussion.should_not_receive(:update_attribute)
      end
    end
  end
end
