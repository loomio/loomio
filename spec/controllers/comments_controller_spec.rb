require 'spec_helper'

describe CommentsController do
  let(:app_controller) { controller }
  let(:user) { stub_model(User) }
  let(:discussion) { mock_model(Discussion) }
  let(:comment) { mock_model(Comment, discussion: discussion) }

  context "authenticated user" do
    before do
      sign_in user
      app_controller.stub(:authorize!).and_return(true)
      app_controller.stub(:resource).and_return(comment)
    end

    context "user likes a comment" do
      before do
        @comment_vote = mock("comment_vote")
        comment.stub(:like, :like => true).and_return(@comment_vote)
        Event.stub(:comment_liked!)
      end

      it "checks permissions" do
        app_controller.should_receive(:authorize!).and_return(true)
        post :like, id: 23, like: 'true'
      end

      it "adds like to comment model" do
        comment.should_receive(:like).with(user)
        post :like, id: 23, like: 'true'
      end

      it "fires comment_liked! event" do
        Event.should_receive(:comment_liked!).with(@comment_vote)
        post :like, id: 23, like: 'true'
      end

    end

    context "user unlikes a comment" do
      before do
        comment.stub(:like).with({'like' => 'false'})
      end

      it "checks permissions" do
        app_controller.should_receive(:authorize!).and_return(true)
        comment.should_receive(:unlike).with(user) #hack? -PS
        post :like, id: 23, like: 'false'
      end

      it "removes like from comment model" do
        comment.should_receive(:unlike).with(user)
        post :like, id: 23, like: 'false'
      end

    end
  end
end
