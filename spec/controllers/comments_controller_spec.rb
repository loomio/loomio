require 'spec_helper'

describe CommentsController do
  let(:comment) { stub_model(Comment) }
  let(:motion) { stub_model(Motion) }
  let(:user) { User.make! }
  let(:user2) { User.make! }
  let(:previous_url) { motion_url(motion) }

  context "logged in user" do
    before :each do
      sign_in user
      request.env["HTTP_REFERER"] = previous_url
      Comment.stub(:find).with(comment.id.to_s).and_return(comment)
    end

    context "user deletes their own comment" do
      it "succeeds and redirects to motion page" do
        comment.stub(:user_id).and_return(user.id)
        comment.stub_chain(:discussion, :motions, :first).and_return(motion)
        comment.should_receive(:destroy)

        delete :destroy, id: comment.id

        flash[:notice].should match(/Comment deleted/)
        response.should redirect_to(motion_path(motion))
      end
    end

    context "user deletes someone else's comment" do
      it "displays error and redirects to motion page" do
        comment.stub(:user_id).and_return(user2.id)

        delete :destroy, id: comment.id

        flash[:error].should match(/Access denied/)
        response.should redirect_to(previous_url)
      end
    end
  end
end
