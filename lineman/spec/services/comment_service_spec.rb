describe 'CommentService' do
  let(:ability) { double(:ability, :authorize! => true, can?: true) }
  let(:user) { double(:user, ability: ability, update_attributes: true) }
  let(:discussion) { double(:discussion, author: user,
                                         save!: true,
                                         valid?: true,
                                         title_changed?: false,
                                         description_changed?: false,
                                         :title= => true,
                                         :description= => true,
                                         :private= => true,
                                         :uses_markdown= => true,
                                         inherit_group_privacy!: nil,
                                         uses_markdown: true,
                                         :iframe_src= => true,
                                         update_attribute: true,
                                         update_attributes: true,
                                         group: true,
                                         private: true,
                                         created_at: Time.now) }
  let(:comment) { double(:comment,
                         save!: true,
                         valid?: true,
                         'author=' => nil,
                         created_at: :a_time,
                         discussion: discussion,
                         destroy: true,
                         author: user) }
  let(:event) { double(:event) }

  describe 'delete' do
    after do
      CommentService.delete(comment: comment, actor: user)
    end

    it 'checks the actor has permission' do
      ability.should_receive(:authorize!).with(:destroy, comment)
    end

    it 'deletes the comment' do
      comment.should_receive :destroy
    end
  end

  describe 'unlike' do
    after do
      CommentService.unlike(comment: comment, actor: actor)
    end

    it 'calls unlike on the comment' do
      comment.should_receive(:unlike).with(user)
    end
  end

  describe 'like' do
    before do
      Events::CommentLiked.stub(:publish!)
      ability.stub(:authorize!)
      comment.stub(:like).and_return(comment_vote)
    end

    after do
      CommentService.like(comment: comment, actor: user)
    end

    it 'checks the user can like the comment' do
      ability.should_receive(:authorize!).with(:like, comment)
    end

    it 'creates a comment vote' do
      comment.should_receive(:like).with(user).and_return(comment_vote)
    end

    it 'enfollows the liker' do
      expect(discussion_reader).to receive(:follow!)
    end

    it 'publishes a like comment event' do
      Events::CommentLiked.should_receive(:publish!).with(comment_vote)
    end
  end

  describe 'create' do
    before do
      Events::NewComment.stub(:publish!).and_return(event)
    end

    after do
      CommentService.create(comment: comment, actor: actor)
    end

    it 'authorizes that the user can add the comment' do
      ability.should_receive(:authorize!).with(:add_comment, discussion)
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
