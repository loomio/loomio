require 'spec_helper'

describe CommentsController do
  let(:app_controller) { controller }
  let(:group) { create :group }
  let(:user) { create :user }
  let(:discussion) { create :discussion, group: group }
  let(:comment) { create :comment, discussion: discussion }

  context "authenticated user" do
    before do
      sign_in user
      group.add_member! user
      Comment.stub(:find).and_return(comment)
    end

    context "user likes a comment" do
      before do
        @comment_vote = mock_model(CommentVote)
        comment.stub(:like, :like => true).and_return(@comment_vote)
        Events::CommentLiked.stub(:publish!)
      end

      it "checks permissions" do
        app_controller.should_receive(:authorize!).and_return(true)
        post :like, id: comment.id, like: 'true'
      end

      it "adds like to comment model" do
        comment.should_receive(:like).with(user)
        post :like, id: comment.id, like: 'true'
      end

      it "fires comment_liked! event" do
        Events::CommentLiked.should_receive(:publish!).with(@comment_vote)
        post :like, id: comment.id, like: 'true'
      end
    end

    context "user unlikes a comment" do
      before do
        comment.stub(:like).with({'like' => 'false'})
      end

      it "checks permissions" do
        app_controller.should_receive(:authorize!).and_return(true)
        comment.should_receive(:unlike).with(user) #hack? -PS
        post :like, id: comment.id, like: 'false'
      end

      it "removes like from comment model" do
        comment.should_receive(:unlike).with(user)
        post :like, id: comment.id, like: 'false'
      end

    end
  end
end
