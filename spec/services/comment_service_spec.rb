require 'rails_helper'
describe 'CommentService' do
  let(:user) { create :user }
  let(:discussion) { create :discussion, author: user }
  let(:comment) { create :comment, discussion: discussion, author: user }
  let(:comment_vote) { create :comment_vote, comment: comment, user: user }
  let(:event) { double(:event) }

  describe 'destroy' do
    after do
      CommentService.destroy(comment: comment, actor: user)
    end

    it 'checks the actor has permission' do
      user.ability.should_receive(:authorize!).with(:destroy, comment)
    end

    it 'deletes the comment' do
      comment.should_receive :destroy
    end
  end

  describe 'create' do
    before do
      Events::NewComment.stub(:publish!).and_return(event)
    end

    after do
      CommentService.create(comment: comment, actor: user)
    end

    it 'authorizes that the user can add the comment' do
      user.ability.should_receive(:authorize!).with(:create, comment)
    end

    it 'saves the comment' do
      comment.should_receive(:save!).and_return(true)
    end

    context 'comment is valid' do
      before do
        comment.stub(:valid?).and_return(true)
      end

      it 'fires a NewComment event' do
        Events::NewComment.should_receive(:publish!).with(comment)
      end

      it 'returns the event created' do
        CommentService.create(comment: comment, actor: user).should == event
      end
    end

    context 'comment is invalid' do
      before do
        comment.stub(:valid?).and_return(false)
      end

      it 'returns false' do
        CommentService.create(comment: comment, actor: user).should == false
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
