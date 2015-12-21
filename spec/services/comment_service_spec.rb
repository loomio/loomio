require 'rails_helper'
describe 'CommentService' do
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:discussion) { create :discussion, author: user }
  let(:comment) { create :comment, discussion: discussion, author: user }
  let(:comment_vote) { create :comment_vote, comment: comment, user: user }
  let(:event) { double(:event) }
  let(:reader) { DiscussionReader.for(user: user, discussion: discussion) }
  let(:comment_params) {{ body: 'My body is ready' }}

  before do
    discussion.group.members << another_user
  end

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

    it 'authorizes that the user can add the comment' do
      user.ability.should_receive(:authorize!).with(:create, comment)
      CommentService.create(comment: comment, actor: user)
    end

    it 'saves the comment' do
      comment.should_receive(:save!).and_return(true)
      CommentService.create(comment: comment, actor: user)
    end

    it 'clears out the draft' do
      draft = create(:draft, user: user, draftable: comment.discussion, payload: { comment: { body: 'body draft' } })
      CommentService.create(comment: comment, actor: user)
      expect(draft.reload.payload['comment']).to be_blank
    end

    context 'comment is valid' do
      before do
        comment.stub(:valid?).and_return(true)
      end

      it 'fires a NewComment event' do
        Events::NewComment.should_receive(:publish!).with(comment)
        CommentService.create(comment: comment, actor: user)
      end

      it 'returns the event created' do
        CommentService.create(comment: comment, actor: user).should == event
      end

      it 'updates the discussion reader' do
        CommentService.create(comment: comment, actor: user)
        expect(reader.reload.participating).to eq true
        expect(reader.reload.volume.to_sym).to eq :loud
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
        CommentService.create(comment: comment, actor: user)
      end

      it 'does not update discussion' do
        discussion.should_not_receive(:update_attribute)
        CommentService.create(comment: comment, actor: user)
      end
    end
  end

  describe 'update' do
    it 'updates a comment' do
      CommentService.update(comment: comment, params: comment_params, actor: user)
      expect(comment.reload.body).to eq comment_params[:body]
    end

    it 'notifies new mentions' do
      comment_params[:body] = "A mention for @#{another_user.username}!"
      expect(Events::UserMentioned).to receive(:publish!).with(comment, another_user)
      CommentService.update(comment: comment, params: comment_params, actor: user)
    end

    it 'does not update an invalid comment' do
      comment_params[:body] = ''
      CommentService.update(comment: comment, params: comment_params, actor: user)
      expect(comment.reload.body).to_not eq comment_params[:body]
    end
  end
end
