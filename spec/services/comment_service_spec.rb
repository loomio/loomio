require 'rails_helper'
describe 'CommentService' do
  let(:user) { create :user }
  let(:another_user) { create :user }
  let(:group) { create(:group) }
  let(:discussion) { create :discussion, group: group, author: user }
  let(:comment) { create :comment, discussion: discussion, author: user }
  let(:reaction) { create :reaction, reactable: comment, user: user }
  let(:reader) { DiscussionReader.for(user: user, discussion: discussion) }
  let(:comment_params) {{ body: 'My body is ready' }}

  before do
    group.add_member! another_user
  end

  describe 'destroy' do

    it 'checks the actor has permission' do
      user.ability.should_receive(:authorize!).with(:destroy, comment)
      CommentService.destroy(comment: comment, actor: user)
    end

    it 'deletes the comment' do
      comment.should_receive :destroy
      CommentService.destroy(comment: comment, actor: user)
    end

    it 'nullifies the parent_id of replies' do
      child = create(:comment, discussion: comment.discussion, parent: comment)
      CommentService.destroy(comment: comment, actor: user)
      expect(child.reload.parent_id).to eq nil
    end
  end

  describe 'create' do

    it 'authorizes that the user can add the comment' do
      user.ability.should_receive(:authorize!).with(:create, comment)
      CommentService.create(comment: comment, actor: user)
    end

    it 'sets my volume to loud' do
      user.update(email_on_participation: true)
      reader = DiscussionReader.for(discussion: comment.discussion, user: user)
      reader.set_volume!("normal")
      CommentService.create(comment: comment, actor: user)
      expect(reader.reload.computed_volume).to eq "loud"
    end

    it 'saves the comment' do
      comment.should_receive(:save!).and_return(true)
      CommentService.create(comment: comment, actor: user)
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
        expect(CommentService.create(comment: comment, actor: user)).to be_a Event
      end

      it 'updates the discussion reader' do
        user.update_attribute(:email_on_participation, false)
        CommentService.create(comment: comment, actor: user)
        expect(reader.reload.computed_volume.to_sym).to eq :normal
      end

      it 'publishes a comment replied to event if there is a parent' do
        comment.parent = create :comment
        Events::CommentRepliedTo.should_receive(:publish!).with(comment)
        CommentService.create(comment: comment, actor: user)
      end

      it 'does not publish a comment replied to event if there is no parent' do
        expect { CommentService.create(comment: comment, actor: user) }.to_not change { Event.where(kind: 'comment_replied_to').count }
      end

      it 'does not send any notifications if the author is the same as the replyee' do
        comment.parent = create :comment, author: user
        expect { CommentService.create(comment: comment, actor: user) }.to_not change { ActionMailer::Base.deliveries.count }
        expect(Notification.count).to eq 0
      end

      it 'does not notify the parent author even if mentioned' do
        comment.parent = create :comment, author: another_user, discussion: discussion
        comment.body = "A mention for @#{another_user.username}!"

        expect { CommentService.create(comment: comment, actor: user) }.to_not change { Event.where(kind: 'user_mentioned').count }
        expect(comment.mentioned_users).to include comment.parent.author
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

    it 'does not renotify old mentions' do
      comment_params[:body] = "A mention for @#{another_user.username}!"
      expect { CommentService.update(comment: comment, params: comment_params, actor: user) }.to change { another_user.notifications.count }.by(1)
      comment_params[:body] = "Hello again @#{another_user.username}"
      expect { CommentService.update(comment: comment, params: comment_params, actor: user) }.to_not change  { another_user.notifications.count }
    end

    it 'does not update an invalid comment' do
      comment_params[:body] = ''
      CommentService.update(comment: comment, params: comment_params, actor: user)
      expect(comment.reload.body).to_not eq comment_params[:body]
    end
  end
end
