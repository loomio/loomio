require_relative '../../app/services/discussion_service'

module Events
  class NewComment
  end
  class CommentLiked
  end
  class NewDiscussion
  end
end

describe 'DiscussionService' do
  let(:comment_vote) { double(:comment_vote) }
  let(:ability) { double(:ability, :authorize! => true, can?: true) }
  let(:user) { double(:user, ability: ability, update_attributes: true) }
  let(:discussion) { double(:discussion, author: user,
                                         save: true,
                                         :title= => true,
                                         :description= => true,
                                         :private= => true,
                                         :uses_markdown= => true,
                                         uses_markdown: true,
                                         :iframe_src= => true,
                                         update_attribute: true,
                                         update_attributes: true,
                                         group: true,
                                         private: true,
                                         created_at: Time.now) }
  let(:comment) { double(:comment,
                         save: true,
                         'author=' => nil,
                         created_at: :a_time,
                         discussion: discussion,
                         destroy: true,
                         author: user) }
  let(:event) { double(:event) }
  let(:discussion_params) { {title: "new title", description: "", private: true, uses_markdown: true} }


  before do
    Events::NewDiscussion.stub(:publish!).and_return(event)
  end

  describe '.delete_comment' do
    after do
      DiscussionService.delete_comment(comment: comment, actor: user)
    end

    it 'checks the actor has permission' do
      ability.should_receive(:authorize!).with(:destroy, comment)
    end

    it 'deletes the comment' do
      comment.should_receive :destroy
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
      ability.stub(:authorize!)
      comment.stub(:like).and_return(comment_vote)
    end

    after do
      DiscussionService.like_comment(user, comment)
    end

    it 'checks the user can like the comment' do
      ability.should_receive(:authorize!).with(:like_comments, discussion)
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

  describe '.start_discussion' do
    it 'authorizes the user can create the discussion' do
      ability.should_receive(:authorize!).with(:create, discussion)
      DiscussionService.start_discussion(discussion)
    end

    it 'saves the discussion' do
      discussion.should_receive(:save).and_return(true)
      DiscussionService.start_discussion(discussion)
    end

    context 'the discussion is valid' do
      before { discussion.stub(:save).and_return(true) }

      it 'updates user markdown-preference' do
        user.should_receive(:update_attributes).with(uses_markdown: discussion.uses_markdown).and_return(true)
        DiscussionService.start_discussion(discussion)
      end

      it 'fires a NewDiscussion event' do
        Events::NewDiscussion.should_receive(:publish!).with(discussion).and_return(true)
        DiscussionService.start_discussion(discussion)
      end

      it 'returns the event created' do
        DiscussionService.start_discussion(discussion).should == event
      end
    end
  end

  describe '.edit-discussion' do
    it 'authorizes the user can update the discussion' do
      ability.should_receive(:authorize!).with(:update, discussion)
      DiscussionService.edit_discussion(user, discussion_params, discussion)
    end

    it 'sets params' do
      discussion.should_receive(:private=).with(discussion_params[:private])
      discussion.should_receive(:title=).with(discussion_params[:title])
      discussion.should_receive(:description=).with(discussion_params[:description])
      discussion.should_receive(:uses_markdown=).with(discussion_params[:uses_markdown])
      DiscussionService.edit_discussion(user, discussion_params, discussion)
    end

    it 'saves the discussion' do
      discussion.should_receive(:save).and_return(true)
      DiscussionService.edit_discussion(user, discussion_params, discussion)
    end

    context 'the discussion is valid' do
      before { discussion.stub(:save).and_return(true) }

      it 'updates user markdown-preference' do
        user.should_receive(:update_attributes).with(uses_markdown: discussion.uses_markdown).and_return(true)
        DiscussionService.edit_discussion(user, discussion_params, discussion)
      end
    end

    context 'the discussion is invalid' do
      before { discussion.stub(:save).and_return(false) }
      it 'returns false' do
        DiscussionService.edit_discussion(user, discussion_params, discussion).should == false
      end

      it 'does not update the user markdown-preference' do
        user.should_not_receive(:update_attributes)
        DiscussionService.edit_discussion(user, discussion_params, discussion)
      end

    end
  end
end
