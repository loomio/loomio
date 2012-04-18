require 'spec_helper'

describe DiscussionsController do
  let(:app_controller) { controller }
  let(:user) { stub_model(User) }
  let(:motion) { mock_model(Motion) }
  let(:discussion) { mock_model(Discussion, default_motion: motion) }

  context "authenticated user" do
    before do
      app_controller.stub(:current_user).and_return(user)
      app_controller.stub(:authenticate_user!).and_return(true)
      app_controller.stub(:authorize!).and_return(true)
      app_controller.stub(:resource).and_return(discussion)
    end

    context "adds comment" do
      before do
        discussion.stub(:add_comment)
      end

      it "checks permissions" do
        app_controller.should_receive(:authorize!).and_return(true)
        post :add_comment, comment: "Hello!", id: 23
      end

      it "adds comment" do
        discussion.should_receive(:add_comment).with(user, "Hello!")
        post :add_comment, comment: "Hello!", id: 23
      end

      it "redirects to the discussion's default motion" do
        post :add_comment, comment: "Hello!", id: 23
        response.should redirect_to(motion_path(motion))
      end
    end
  end
end
