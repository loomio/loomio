require_relative '../../app/services/add_comment_service'

module Events
  class NewComment
  end
end

describe 'DiscussionService' do
  let(:ability) { double(:ability, :authorize! => true) }
  let(:user) { double(:user, ability: ability) }
  let(:comment) { double(:comment, save: true, 'author=' => nil, created_at: :a_time, 'discussion=' => nil) }
  let(:discussion) { double(:discussion, update_attribute: true) }
  let(:event) { double(:event) }

  before do
    Events::NewComment.stub(:publish!).and_return(event)
  end

  describe 'add_comment' do
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
